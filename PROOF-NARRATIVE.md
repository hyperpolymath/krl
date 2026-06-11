<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Proof Narrative — KRL

This file is the **single coherent story** of what KRL proves, what it
assumes, and what it has left to prove. It is the document a reader
should open first when asking _"is this language sound, and how do I
know?"_.

For the per-obligation status checklist, see [PROOF-NEEDS.md](PROOF-NEEDS.md).
For the registry of every load-bearing unproven assumption, see
[ASSUMPTIONS.md](ASSUMPTIONS.md).

---

## 1. Position in the stack

KRL is the **surface language** of a four-layer federated stack. It is
*not* a standalone implementation; the canonical implementations live
in sibling repos:

```
┌─────────────────────────────────────────────────────────┐
│  KRL surface language  (this repo)                      │
│    • spec/grammar.ebnf  (v0.1.0)                        │
│    • Idris2 ABI types   (src/interface/Abi/)            │
│    • Zig FFI scaffold   (src/interface/ffi/)            │
│    • examples           (examples/)                     │
└─────────────────┬───────────────────────────────────────┘
                  │ implements
                  ▼
┌─────────────────────────────────────────────────────────┐
│  KRLAdapter.jl         — canonical parser / lower       │
│  quandledb/server/krl/ — server-side query parser       │
└─────────────────┬───────────────────────────────────────┘
                  │ lowers to
                  ▼
┌─────────────────────────────────────────────────────────┐
│  TangleIR               — canonical interchange object  │
└─────────────────┬───────────────────────────────────────┘
                  │ semantics on
                  ▼
┌─────────────────────────────────────────────────────────┐
│  Tangle (hyperpolymath/tangle)  — proven core           │
│    Progress · Preservation · Determinism · Type Safety  │
└─────────────────┬───────────────────────────────────────┘
                  │ persisted+queried via
                  ▼
┌─────────────────────────────────────────────────────────┐
│  Skein.jl + QuandleDB   — storage + semantic index      │
└─────────────────────────────────────────────────────────┘
```

Consequence: **this repo's proof obligations are spec-level, not
implementation-level**. We owe a precise definition of what a KRL
program *is*, plus refinement-style obligations against the two
parser implementations.

## 2. Proven now

| ID | Statement | Form | Where |
|----|-----------|------|-------|
| — | _none yet at the KRL surface level_ | — | — |

The Idris2 / Lean / Coq files previously sitting under
`verification/proofs/` were rsr-template-repo boilerplate (generic
`Bounded`, `ApiResult`, typed-arithmetic `TypeSafety`). They asserted
nothing about KRL. They have been deleted in the same PR as this
narrative to avoid the "looks proven, isn't" failure mode. Their
content is recoverable from the PR description if anyone wants the
template back.

**The actually-proven results that the KRL stack benefits from live
in `hyperpolymath/tangle/proofs/Tangle.lean`** (16 theorems and
lemmas including Progress, Preservation, Determinism, and Type Safety
for the core Tangle calculus that KRL lowers into). See the tangle
repo's `PROOF-NARRATIVE.md` for details. Until KRL has its own surface
proofs, the soundness story rests on (a) the Tangle core proofs and
(b) the *unproven* claim that KRL faithfully lowers into that core.
That claim is `KR-1` and `KR-2` below.

## 3. Obligations (the narrative arc)

The arc from "KRL text" to "trusted query result":

```
KRL source text
   │ [KR-7]  parser rejects ill-typed concrete syntax
   ▼
KRLProgram AST
   │ [KR-1]  lowering is total on parseable programs
   │ [KR-2]  lowering preserves port arity
   ▼
TangleIR
   │ [hyperpolymath/tangle: T-Progress, T-Preservation, T-Determinism]
   ▼
Tangle value
   │ [KR-3]  simplify is semantics-preserving
   │ [KR-8]  equivalent? is sound w.r.t. fundamental-quandle iso
   ▼
Query result
```

Each obligation in detail:

### KR-1 — Lowering is total on parseable programs

**Claim.** For every `KRLProgram p` produced by `parse_krl`, the
function `lower(p)` returns a `TangleIR` (never raises `KRLLowerError`).

**Why valuable.** A `KRLLowerError` at runtime means the parser
accepted a program that the lowering rejected — a soundness regression
that the lexer/parser/AST should have prevented. Closing this proves
parser-and-lowering agree on the language.

**Status.** Unproven. Currently `KRLLowerError` is raised from
`KRLAdapter.jl/src/parser/lower.jl` on (a) unbound identifiers and
(b) un-matched AST variants. Case (a) is correct (it's a real user
error); case (b) is the soundness gap.

**Assumptions (load-bearing for this claim).**
- [[A-KR-1.1]] Every `KRLExpr` AST variant has a matching arm in `lower.jl`.
- [[A-KR-1.2]] The AST defined in `KRLAdapter.jl/src/parser/ast.jl` is
  the *only* AST shape the parser can produce.

**How to discharge.** Add an exhaustiveness check to the lowering
function (compile-time in Julia is weak; consider a property-based
test enumerating every constructor as a stop-gap, with Idris2 as the
target prover for the long term).

### KR-2 — Lowering preserves port arity

**Claim.** If `p : KRLProgram` lowers to `ir : TangleIR`, then for
every sub-expression `(compose a b)` in `p`, the number of output
ports of `lower(a)` equals the number of input ports of `lower(b)`.

**Why valuable.** Composition is the central operation. Without this,
you can write KRL that lowers to ill-formed TangleIR — e.g. composing
a 2-strand braid with a 3-strand tangle — and the error surfaces
downstream as garbled invariant computation, not as a clear "your
program is wrong" message.

**Status.** Unproven, and the typechecker that would enforce this at
parse time is **not yet implemented** (acknowledged in `READINESS.md`
under "Path to C").

**Assumptions.**
- [[A-KR-2.1]] Generators have known fixed arity:
  `sigma i : in=i, out=i+1` (and same arity in/out), `cup i : in=0,
  out=2`, `cap i : in=2, out=0`.
- [[A-KR-2.2]] Tensor and compose distribute over arity in the obvious
  way: `arity_in(a | b) = arity_in(a) + arity_in(b)`.

**How to discharge.** Implement port-arity checking in the
typechecker; prove the typechecker sound against this property.

### KR-3 — `simplify` is semantics-preserving

**Claim.** For every `e : KRLExpr` and its simplified form
`e' = simplify(e)`, the lowered TangleIR objects `lower(e)` and
`lower(e')` represent the same tangle up to isotopy.

**Why valuable.** This is the *retrieval guarantee*: queries against
the simplified form must return the same answer as queries against
the original. Without it, simplification is a performance trick that
can change semantics.

**Status.** Unproven; `simplify` is partially implemented in
KRLAdapter.jl (R2 detection works inside a single sigma sequence but
not across `compose` boundaries — see `READINESS.md`).

**Assumptions.**
- [[A-KR-3.1]] R1, R2, R3 are the complete set of local moves needed
  to relate isotopic tangles (Reidemeister's theorem; mathematically
  established).
- [[A-KR-3.2]] `r1_simplify`, `r2_simplify`, `r3_simplify` (when
  implemented; R3 is currently a gap — see
  `quandledb/PROOF-NARRATIVE.md` QD-2) faithfully implement those moves.

**How to discharge.** Prove each rewrite preserves the fundamental
quandle presentation (which encodes isotopy).

### KR-4 — Pretty-print/parse round-trip

**Claim.** For every `e : KRLExpr` produced by `parse_krl`,
`parse_krl(pretty(e)) = e`.

**Why valuable.** A free fuzz oracle. Catches a whole class of "lossy
IR" bugs at the parse boundary. Also the foundation of the
`reconstruct_source` claim in `README.adoc`.

**Status.** Unproven; `pretty` exists in KRLAdapter.jl but no
round-trip test.

**Assumptions.**
- [[A-KR-4.1]] The pretty-printer's choice of bracketing is
  unambiguous w.r.t. the grammar (e.g. `;` only inside parens at the
  expression level — see `READINESS.md`).

**How to discharge.** Add a property test in `KRLAdapter.jl/test/`
that round-trips every well-formed program from `examples/`.

### KR-5 — Idris2/Zig ABI primitives are load-bearing

**Claim.** `SafePtr`, `Handle`, `Bounded`, `NonEmpty` (currently in
`src/interface/Abi/` and `verification/proofs/idris2/`) must either be
**referenced by the actual Zig FFI surface** or be deleted.

**Why valuable.** Right now they're floating. They were rsr-template
content; they have non-trivial dependent-type structure but no
consumer.

**Status.** Decision pending. Recommended decision: keep `SafePtr` and
`Handle`, wire them through the FFI; delete `Bounded` and `NonEmpty`
as unused.

### KR-6 — Two-parser equivalence

**Claim.** For every input string `s`, `KRLAdapter.jl::parse_krl(s)`
and `quandledb/server/krl/Parser.jl::parse_any(s)` either both
succeed with equal ASTs or both fail.

**Why valuable.** The two implementations exist by design — one for
end-user code, one for query-time parsing — but if they accept
different languages, the server can run queries the user can't write,
and vice versa.

**Status.** Unproven; no differential test exists.

**Assumptions.**
- [[A-KR-6.1]] Both implementations target the same EBNF grammar
  (`spec/grammar.ebnf` v0.1.0).
- [[A-KR-6.2]] Both implementations have the same notion of "valid
  identifier", "valid integer literal", "valid string literal".

**How to discharge.** Build a differential fuzz harness that feeds
random strings to both and asserts result equivalence. Easy single PR.

### KR-7 — Generator-index validity

**Claim.** `sigma N`, `sigma_inv N`, `cup N`, `cap N` are accepted iff
`N ≥ 1`.

**Why valuable.** Small but catches a real class of off-by-one bugs;
also a parser-level invariant that should be asserted explicitly.

**Status.** Currently encoded in the existing parser-error case
("zero index" rejected). Not asserted as a property test.

### KR-8 — `equivalent?` is sound w.r.t. quandle isomorphism

**Claim.** If `equivalent?(a, b)` returns `true`, then the fundamental
quandles of `a` and `b` are isomorphic.

**Why valuable.** This is the central claim of the retrieval layer.
False positives mean the database lies; without this, `equivalent?` is
heuristic, not semantic.

**Status.** Unproven; implementation in QuandleDB. Soundness rests on
[[A-KR-8.1]] and the fingerprint determinism claim
`quandledb/PROOF-NARRATIVE.md` QD-4.

**Assumptions.**
- [[A-KR-8.1]] Fundamental-quandle functor is *faithful* on isotopy
  classes (true for prime alternating knots; partial in general — this
  needs to be a stated and bounded assumption).
- [[A-KR-8.2]] Fingerprint collisions are mathematically impossible
  for non-isomorphic quandles (this is a property of the
  canonicalisation, not the hash).

**How to discharge.** Either:
- Restrict the claim to the prime-alternating subset (where the
  functor is provably faithful), or
- State the obligation as "equivalence is sound modulo the
  fundamental-quandle relation", which is weaker but provable.

## 4. The "stupid proof" exclusions

For completeness, things we deliberately do **not** prove:

- _"`KRLProgram` is a record with these fields"_ — enforced by the
  Julia type system; no proof needed.
- _"`parse_krl` returns a `KRLProgram`"_ — Julia type assertion.
- _"Compose is associative when types agree"_ — implied by list-append
  associativity.
- _"BLAKE3 is collision-resistant"_ — out of scope; cryptographic
  primitive assumption inherited from QuandleDB.

If you find yourself drafting a proof in one of these categories,
delete the draft.

## 5. How to add a new obligation

1. Add an entry to [PROOF-NEEDS.md](PROOF-NEEDS.md) with an ID
   (`KR-N`), category, prover, priority, effort estimate.
2. Add the narrative entry here: statement, _why valuable_,
   status, **assumptions**, how to discharge. The assumptions block
   is non-optional.
3. For each new assumption, add an entry to
   [ASSUMPTIONS.md](ASSUMPTIONS.md) with an ID (`A-KR-N.M`) and a
   note on whether it is _mathematical_ (true by external theorem),
   _design_ (true by our construction), or _empirical_ (believed,
   not verified).

## 6. References

- Architecture: [README.adoc](README.adoc), section "Architecture position".
- Companion narratives:
  - `hyperpolymath/tangle/PROOF-NARRATIVE.md` — semantic core proofs
  - `hyperpolymath/quandledb/PROOF-NARRATIVE.md` — quandle / DB proofs
- Implementations:
  - `KRLAdapter.jl` — canonical parser, AST, lower
  - `quandledb/server/krl/` — server-side query parser
- Spec: [spec/grammar.ebnf](spec/grammar.ebnf), [spec/grammar-overview.md](spec/grammar-overview.md).
