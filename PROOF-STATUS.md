<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Proof Status — KRL

> Requirements: [PROOF-NEEDS.md](PROOF-NEEDS.md).
> Single coherent story: [PROOF-NARRATIVE.md](PROOF-NARRATIVE.md).
> Assumption registry: [ASSUMPTIONS.md](ASSUMPTIONS.md).

This file tracks the per-obligation status. Updated 2026-06-01.

## Summary

| Category | Total | Done | In Progress | Partial | Blocked | Not Started |
|----------|-------|------|-------------|---------|---------|-------------|
| Typing (TP) | 2 | 0 | 0 | 0 | 0 | 2 |
| Invariant (INV) | 3 | 0 | 0 | 1 | 0 | 2 |
| Algorithm (ALG) | 1 | 0 | 0 | 1 | 0 | 0 |
| ABI (ABI) | 1 | 0 | 0 | 0 | 0 | 1 (decision pending) |
| Domain (DOM) | 1 | 0 | 0 | 0 | 0 | 1 |
| **Total** | **8** | **0** | **0** | **2** | **0** | **6** |

**Overall:** 0% proven, 25% partial.

The partial entries (`KR-3` simplification across compose() and
`KR-7` generator index validity) have implementations or smoke
coverage but no property test or formal proof.

## Proofs done

| ID | Proof | Prover | File | Date | Verified by |
|----|-------|--------|------|------|-------------|
| — | none yet at the KRL surface level | — | — | — | — |

The Tangle core proofs (Progress, Preservation, Determinism,
Type Safety + 12 lemmas, 16 results total) in
`hyperpolymath/tangle/proofs/Tangle.lean` are foundational for KRL
because KRL lowers into Tangle. They are tracked in tangle's
PROOF-STATUS, not here.

## Proofs in progress

| ID | Proof | Prover | Assignee | Started | Blocker |
|----|-------|--------|----------|---------|---------|
| — | — | — | — | — | — |

## Proofs partial

| ID | Proof | Form | Notes |
|----|-------|------|-------|
| KR-3 | `simplify` semantics-preserving | Property test in `KRLAdapter.jl/test/` | R1 + R2 (within a single sigma sequence) covered. R2 across `compose()` not covered. R3 implementation gap. See `quandledb/PROOF-NARRATIVE.md` QD-2. |
| KR-7 | `sigma N` accepted iff `N ≥ 1` | Parser error path | Not property-tested. |

## Proofs blocked

| ID | Proof | Blocked by |
|----|-------|------------|
| KR-2 | Lowering preserves port arity | Typechecker not yet implemented (see `READINESS.md`) |
| KR-3c | R3 invariance | `KnotTheory.jl` has no R3 simplifier (see quandledb QD-2) |

## Proofs remaining

| ID | Proof | Category | Prover | Priority | Effort |
|----|-------|----------|--------|----------|--------|
| KR-1 | `lower` total on parseable programs | TP | Idris2 + property test | P1 | 1d |
| KR-2 | `lower` preserves port arity | TP | Idris2 + impl | P1 | 3d |
| KR-3 | `simplify` semantics-preserving | ALG | Lean4 / property | P1 | 5d |
| KR-4 | Pretty/parse round-trip | INV | Property | P1 | 4h |
| KR-5 | ABI primitives load-bearing | ABI | Decision | P3 | 2h |
| KR-6 | Two-parser equivalence | INV | Differential property test | P1 | 4h |
| KR-7 | Generator index validity | INV | Property test | P2 | 1h |
| KR-8 | `equivalent?` sound | DOM | Lean4 (via QuandleDB QD-3) | P1 | 5d |

## Verification commands

```bash
# Check all Idris2 proofs
just proof-check-idris2

# Check all Lean4 proofs
just proof-check-lean4

# Run all proof checks
just proof-check-all

# Scan for dangerous patterns
panic-attack assail --proofs-only
```

## Changelog

| Date | Change | By |
|------|--------|-----|
| 2026-04-04 | Initial proof status tracking | Template (rsr-template-repo) |
| 2026-06-01 | Replaced template-content scaffold with KRL-specific obligations KR-1..KR-8. Deleted template-content proof files (Coq/Lean/Idris) that had zero KRL content. | Audit |
