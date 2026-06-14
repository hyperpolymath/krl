{-# OPTIONS --safe #-}
-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ===========================================================================
-- KRL generator-index validity  —  machine-checked under `agda --safe`
-- ===========================================================================
--
-- Discharges obligation KR-7 from PROOF-NEEDS.md (was "PARTIAL: error path
-- exists, not property-tested"):
--
--   KR-7  `sigma N`, `sigma_inv N`, `cup N`, `cap N` are accepted iff N ≥ 1.
--
-- KRL generators are written with a 1-based strand index (spec/grammar.ebnf:
-- `crossing_gen = "sigma" , integer`, etc.).  Index 0 names no strand pair
-- and must be rejected at parse time.  This module gives the reference
-- semantics of that check and proves it correct in both directions; the
-- Julia parser is property-tested against the same invariant.

module GeneratorIndex where

open import Data.Nat using (ℕ; zero; suc; _≤_; s≤s; z≤n)
open import Data.Maybe using (Maybe; just; nothing)
open import Data.Product using (∃; _,_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)

-- A *validated* 1-based generator index: a number together with a proof it
-- is at least 1.  This is the shape the parser must guarantee downstream.
record Index : Set where
  constructor idx
  field
    value : ℕ
    valid : 1 ≤ value

-- The parser's index check: accept iff the raw integer is ≥ 1.
checkIndex : ℕ → Maybe Index
checkIndex zero    = nothing
checkIndex (suc n) = just (idx (suc n) (s≤s z≤n))

-- ── KR-7, the two directions ───────────────────────────────────────────────

-- completeness: every N ≥ 1 is accepted.
accepts-iff-pos : ∀ {n} → 1 ≤ n → ∃ λ i → checkIndex n ≡ just i
accepts-iff-pos {suc n} _ = idx (suc n) (s≤s z≤n) , refl

-- soundness: anything accepted was ≥ 1.
accepted-is-pos : ∀ {n i} → checkIndex n ≡ just i → 1 ≤ n
accepted-is-pos {suc n} _ = s≤s z≤n
accepted-is-pos {zero}  ()

-- ── Concrete computational evidence ────────────────────────────────────────

-- `sigma 0` (index 0) is rejected.
rejects-zero : checkIndex 0 ≡ nothing
rejects-zero = refl

-- `sigma 1` (index 1) is accepted.
accepts-one : checkIndex 1 ≡ just (idx 1 (s≤s z≤n))
accepts-one = refl
