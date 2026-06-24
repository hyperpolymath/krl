<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Proof Requirements — KRL

> The single coherent story is [PROOF-NARRATIVE.md](PROOF-NARRATIVE.md).
> The assumption registry is [ASSUMPTIONS.md](ASSUMPTIONS.md).
> This file is the **per-obligation checklist** with status, prover, priority.

## Proof Tier

**Tier:** T2 — High.
KRL is the surface language of a federated stack whose correctness
claims (semantic-equivalence queries, isotopy-respecting retrieval)
rest on KRL→TangleIR lowering being trustworthy. The semantic core
(TangleIR/Tangle) is already partially proven; KRL's job is to
guarantee faithful lowering.

## Proof categories

| Code | Meaning | Applies? |
|------|---------|----------|
| **TP** | Typing proofs (port-arity, lowering totality) | Yes |
| **INV** | Invariant proofs (round-trip, grammar refinement) | Yes |
| **SEC** | Security proofs | No |
| **CONC** | Concurrency proofs | No |
| **ALG** | Algorithm proofs (simplification correctness) | Yes |
| **ABI** | ABI/FFI proofs (Zig FFI boundary, Idris2 layout) | Yes (low priority) |
| **DOM** | Domain proofs (quandle equivalence soundness) | Yes |

## Obligations

| # | Statement | Category | Prover | Priority | Effort | Status |
|---|-----------|----------|--------|----------|--------|--------|
| KR-1 | `lower` is total on parseable programs | TP | Idris2 + Julia property test | P1 | 1d | NOT STARTED |
| KR-2 | `lower` preserves port arity | TP | Idris2 + typechecker impl | P1 | 3d | NOT STARTED (typechecker not implemented) |
| KR-3 | `simplify` is semantics-preserving (KR-3a: R1; KR-3b: R2; KR-3c: R3) | ALG | Lean4 or property test against quandle iso | P1 | 5d | PARTIAL (R2 across compose() is gap) |
| KR-4 | Pretty/parse round-trip: `parse(pretty(e)) = e` | INV | Julia property test (cheap) | P1 | 4h | NOT STARTED |
| KR-5 | Idris2 `SafePtr` / `Handle` are load-bearing in the Zig FFI surface | ABI | Decision + wiring | P3 | 2h | DECISION PENDING |
| KR-6 | `KRLAdapter.jl::parse_krl` ≡ `quandledb/server/krl::parse_any` on the v0.1.0 grammar | INV | Differential property test | P1 | 4h | NOT STARTED |
| KR-7 | `sigma N`, `cup N`, etc. accepted iff `N ≥ 1` | INV | Grammar smoke test extension | P2 | 1h | PARTIAL (error path exists, not property-tested) |
| KR-8 | `equivalent?` is sound w.r.t. fundamental-quandle isomorphism | DOM | Lean4 (factored through QuandleDB's QD-3) | P1 | 5d | NOT STARTED |

For full statements, _why valuable_, and the assumptions each
obligation rests on, see [PROOF-NARRATIVE.md](PROOF-NARRATIVE.md).
For the assumptions themselves, see [ASSUMPTIONS.md](ASSUMPTIONS.md).

## Dangerous patterns (BANNED)

CI rejects any PR introducing any of these:

| Pattern | Language | Meaning |
|---------|----------|---------|
| `believe_me` | Idris2 | Unsafe cast |
| `assert_total` | Idris2 | Skip totality check |
| `postulate` | Idris2 / Agda | Unproven axiom |
| `sorry` | Lean4 | Incomplete proof |
| `Admitted` | Coq | Incomplete proof |
| `unsafeCoerce` | Haskell | Unsafe cast |
| `Obj.magic` | OCaml / ReScript | Unsafe cast |
| `unsafe` (unaudited) | Rust | Unsafe block without safety comment |

Enforced by `panic-attack assail --proofs-only`.

## Where proofs go

```
verification/proofs/
├── idris2/   — ABI / type-level invariants (KR-1, KR-2, KR-5)
├── lean4/    — Semantic claims (KR-3, KR-8)
└── julia/    — Property tests against KRLAdapter.jl (KR-4, KR-6, KR-7)
```

(The previous `coq/` directory has been removed; obligations have
been re-allocated to Lean4 where the Tangle metatheory lives.)

## References

- Companion narratives:
  `hyperpolymath/tangle/PROOF-NARRATIVE.md` (semantic core),
  `hyperpolymath/quandledb/PROOF-NARRATIVE.md` (quandle / DB).
- Implementations under proof: `KRLAdapter.jl`, `quandledb/server/krl/`.
