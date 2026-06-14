{-# OPTIONS --safe #-}
-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ===========================================================================
-- KRL port-arity proof  —  machine-checked under `agda --safe` (no unproven axioms)
-- ===========================================================================
--
-- Discharges two obligations from PROOF-NEEDS.md / PROOF-NARRATIVE.md:
--
--   KR-1  `lower` is total on parseable programs
--         (a parseable program never gets "stuck" in lowering; the only
--          failure is a genuine arity mismatch reported cleanly as `nothing`).
--
--   KR-2  `lower` preserves port arity
--         (every sub-expression `(compose a b)` is lowered only when
--          out-ports(a) = in-ports(b), and the lowered TangleIR object has
--          exactly the surface arity).
--
-- Modelled fragment — the CONSTRUCT + TRANSFORM + RESOLVE(close) fragment of
-- KRL v0.1.0 (spec/grammar.ebnf): generators sigma / sigma_inv / cup / cap,
-- sequential composition `;`, tensor `|`, the arity-preserving transforms
-- mirror / simplify / normalise, and `close` (trace / closure).
--
-- Arity model — a *precise* refinement of ASSUMPTIONS A-KR-2.1 / A-KR-2.2.
-- The narrative prose for `sigma` ("in=i, out=i+1 (and same arity in/out)")
-- is internally contradictory and cannot be encoded as written; we take the
-- standard PROP / oriented-Temperley-Lieb model, which honours the
-- *consistent* part of the assumption (cup/cap exact; sigma arity-preserving):
--
--     sigma i, sigma_inv i : 2 → 2     (a crossing; in = out, per A-KR-2.1)
--     cup i                : 0 → 2     (exactly A-KR-2.1)
--     cap i                : 2 → 0     (exactly A-KR-2.1)
--     a ; b   (compose)    : m → n     requires out(a) = in(b)
--     a | b   (tensor)     : (mₐ+m_b) → (nₐ+n_b)   (exactly A-KR-2.2)
--     mirror/simplify/normalise        : arity-preserving
--     close                : n → n  ↦  0 → 0       (trace; requires square)
--
-- Validated against the canonical example from spec/grammar-overview.md,
--     close (sigma 1 ; sigma 1 ; sigma 1)   -- the trefoil
-- which is well-formed with closed arity 0 → 0 (see `trefoil-lowers` below).
-- The strand index `i` is retained as data; KRL v0.1.0 has no strand-count
-- parameterisation (grammar-overview "Known gaps" #3), so locally it does not
-- constrain arity.  A future strand-indexed refinement is left open.
--
-- The RETRIEVE family (`find … where …` queries) and `classify` produce
-- non-tangle results and are out of scope for the port-arity theorem.

module PortArity where

open import Data.Nat using (ℕ; zero; suc; _+_)
open import Data.Nat.Properties using (_≟_; ≟-diag)
open import Data.Maybe using (Maybe; just; nothing)
open import Data.Product using (Σ; Σ-syntax; _×_; _,_; proj₁; proj₂)
open import Data.Empty using (⊥-elim)
open import Relation.Nullary using (yes; no)
open import Relation.Binary.PropositionalEquality
  using (_≡_; _≢_; refl; cong)

-- ───────────────────────────────────────────────────────────────────────────
-- Surface syntax: a *parseable* KRL tangle expression (untyped).
-- ───────────────────────────────────────────────────────────────────────────

data Expr : Set where
  sigma sigmaInv cup cap          : ℕ → Expr
  _⨾_ _⊗_                         : Expr → Expr → Expr   -- compose ; , tensor |
  mirror simplify normalise close : Expr → Expr

infixl 5 _⨾_
infixl 6 _⊗_

-- ───────────────────────────────────────────────────────────────────────────
-- TangleIR: intrinsically port-typed.  `Tangle m n` is a tangle with m input
-- ports and n output ports.  The `Kseq` constructor makes an arity-mismatched
-- composition *unrepresentable* — this is KR-2 baked into the type of the IR.
-- ───────────────────────────────────────────────────────────────────────────

data Tangle : ℕ → ℕ → Set where
  Kσ   : ℕ → Tangle 2 2
  Kσ⁻  : ℕ → Tangle 2 2
  K∪   : ℕ → Tangle 0 2
  K∩   : ℕ → Tangle 2 0
  Kseq : ∀ {m k n} → Tangle m k → Tangle k n → Tangle m n
  Kpar : ∀ {m n p q} → Tangle m n → Tangle p q → Tangle (m + p) (n + q)
  Kmir : ∀ {m n} → Tangle m n → Tangle m n
  Ksim : ∀ {m n} → Tangle m n → Tangle m n
  Knrm : ∀ {m n} → Tangle m n → Tangle m n
  Kcls : ∀ {n} → Tangle n n → Tangle 0 0

-- A lowered object packaged with its (input,output) arity.
TypedTangle : Set
TypedTangle = Σ[ mn ∈ ℕ × ℕ ] Tangle (proj₁ mn) (proj₂ mn)

arity : ∀ {m n} → Tangle m n → ℕ × ℕ
arity {m} {n} _ = m , n

-- ───────────────────────────────────────────────────────────────────────────
-- The lowering, in combinator style so the per-constructor equations hold
-- definitionally (which keeps the proofs below clean).
-- ───────────────────────────────────────────────────────────────────────────

-- sequential composition: succeeds iff the middle arities agree
seqC : TypedTangle → TypedTangle → Maybe TypedTangle
seqC ((ma , ka) , ta) ((kb , nb) , tb) with ka ≟ kb
... | yes refl = just ((ma , nb) , Kseq ta tb)
... | no  _    = nothing

-- tensor: always succeeds, arities add
parC : TypedTangle → TypedTangle → Maybe TypedTangle
parC ((ma , na) , ta) ((mb , nb) , tb) =
  just ((ma + mb , na + nb) , Kpar ta tb)

-- arity-preserving unary transform
mapC : (∀ {m n} → Tangle m n → Tangle m n) → TypedTangle → TypedTangle
mapC f (mn , t) = mn , f t

-- closure / trace: succeeds iff the diagram is square (in = out)
clsC : TypedTangle → Maybe TypedTangle
clsC ((m , n) , t) with m ≟ n
... | yes refl = just ((0 , 0) , Kcls t)
... | no  _    = nothing

-- binary / unary Maybe plumbing (propagates `nothing`)
bind₂ : Maybe TypedTangle → Maybe TypedTangle →
        (TypedTangle → TypedTangle → Maybe TypedTangle) → Maybe TypedTangle
bind₂ (just x) (just y) f = f x y
bind₂ _        _        _ = nothing

mapMaybe : (TypedTangle → TypedTangle) → Maybe TypedTangle → Maybe TypedTangle
mapMaybe f (just x) = just (f x)
mapMaybe _ nothing  = nothing

bind₁ : Maybe TypedTangle → (TypedTangle → Maybe TypedTangle) → Maybe TypedTangle
bind₁ (just x) f = f x
bind₁ nothing  _ = nothing

-- The lowering function.  Total: structural recursion accepted by Agda's
-- own totality checker under `--safe` (no escape hatches): this *is* the
-- witness for KR-1.
compile : Expr → Maybe TypedTangle
compile (sigma i)     = just ((2 , 2) , Kσ  i)
compile (sigmaInv i)  = just ((2 , 2) , Kσ⁻ i)
compile (cup i)       = just ((0 , 2) , K∪  i)
compile (cap i)       = just ((2 , 0) , K∩  i)
compile (a ⨾ b)       = bind₂ (compile a) (compile b) seqC
compile (a ⊗ b)       = bind₂ (compile a) (compile b) parC
compile (mirror e)    = mapMaybe (mapC Kmir) (compile e)
compile (simplify e)  = mapMaybe (mapC Ksim) (compile e)
compile (normalise e) = mapMaybe (mapC Knrm) (compile e)
compile (close e)     = bind₁ (compile e) clsC

-- alias under the obligation's name
lower : Expr → Maybe TypedTangle
lower = compile

-- ===========================================================================
-- KR-2  —  port-arity preservation
-- ===========================================================================

-- (definitional) the lowered IR has exactly the arity `compile` reports.
lower-preserves-arity :
  ∀ e {mn} {t : Tangle (proj₁ mn) (proj₂ mn)} →
  compile e ≡ just (mn , t) → arity t ≡ mn
lower-preserves-arity _ _ = refl

-- helper: `seqC` only fires when the middle arities are equal …
seqC-nomatch :
  ∀ {ma ka kb nb} (ta : Tangle ma ka) (tb : Tangle kb nb) →
  ka ≢ kb → seqC ((ma , ka) , ta) ((kb , nb) , tb) ≡ nothing
seqC-nomatch {_} {ka} {kb} ta tb ne with ka ≟ kb
... | yes p = ⊥-elim (ne p)
... | no  _ = refl

-- (general) a composition is lowered only when out-ports(a) = in-ports(b);
-- a genuine mismatch is rejected cleanly as `nothing`.
compose-mismatch-rejected :
  ∀ {a b ma ka kb nb} {ta : Tangle ma ka} {tb : Tangle kb nb} →
  compile a ≡ just ((ma , ka) , ta) →
  compile b ≡ just ((kb , nb) , tb) →
  ka ≢ kb →
  compile (a ⨾ b) ≡ nothing
compose-mismatch-rejected pa pb ne
  rewrite pa | pb = seqC-nomatch _ _ ne

-- helper: `seqC` fires when the middle arities agree.
seqC-match :
  ∀ {ma k n} (ta : Tangle ma k) (tb : Tangle k n) →
  seqC ((ma , k) , ta) ((k , n) , tb) ≡ just ((ma , n) , Kseq ta tb)
seqC-match {_} {k} ta tb rewrite ≟-diag {k} {k} refl = refl

-- ===========================================================================
-- KR-1  —  lowering is total on parseable programs (no "stuck" states)
-- ===========================================================================

-- (general, positive) matching arities ⇒ the composition lowers, and the
-- lowered IR is exactly the sequential composition of the parts.
compose-succeeds-on-match :
  ∀ {a b ma k n} (ta : Tangle ma k) (tb : Tangle k n) →
  compile a ≡ just ((ma , k) , ta) →
  compile b ≡ just ((k , n) , tb) →
  compile (a ⨾ b) ≡ just ((ma , n) , Kseq ta tb)
compose-succeeds-on-match ta tb pa pb
  rewrite pa | pb = seqC-match ta tb

-- ===========================================================================
-- Concrete computational evidence (each is `refl` — `compile` actually runs)
-- ===========================================================================

-- the canonical trefoil  close (sigma 1 ; sigma 1 ; sigma 1)  lowers,
-- with closed arity 0 → 0.
trefoil : Expr
trefoil = close ((sigma 1 ⨾ sigma 1) ⨾ sigma 1)

trefoil-lowers :
  compile trefoil
    ≡ just ((0 , 0) , Kcls (Kseq (Kseq (Kσ 1) (Kσ 1)) (Kσ 1)))
trefoil-lowers = refl

-- tensor of two cups:  (0→2) | (0→2)  =  0 → 4
two-cups : compile (cup 1 ⊗ cup 2) ≡ just ((0 , 4) , Kpar (K∪ 1) (K∪ 2))
two-cups = refl

-- a genuine arity mismatch — sigma (2→2) then cup (0→2), 2 ≠ 0 — is rejected
-- as `nothing` (a clean error), never "stuck".
mismatch-rejected : compile (sigma 1 ⨾ cup 1) ≡ nothing
mismatch-rejected = refl

-- a non-square diagram cannot be closed:  cup (0→2) has 0 ≠ 2, so `close` fails.
close-needs-square : compile (close (cup 1)) ≡ nothing
close-needs-square = refl
