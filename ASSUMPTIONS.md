<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Assumptions Registry — KRL

Every load-bearing **unproven** assumption used in this repo, with an
ID, classification, and the obligation it supports.

Classifications:
- **MATH** — true by an external mathematical theorem (cite it)
- **DESIGN** — true by construction in our code (must remain true; flag if you change the named code)
- **EMPIRICAL** — believed from testing; not formally verified
- **CRYPTO** — standard cryptographic-primitive assumption

Cross-references use `[[A-KR-N.M]]` syntax, resolved here.

---

| ID | Class | Status | Statement | Cited by | Where it lives |
|----|-------|--------|-----------|----------|----------------|
| A-KR-1.1 | DESIGN | **UNANCHORED** | Every `KRLExpr` AST variant has a matching arm in the lowering pass | KR-1 | was `KRLAdapter.jl/src/parser/lower.jl` — gone; no lowering pass exists anywhere |
| A-KR-1.2 | DESIGN | **UNANCHORED** | The AST module defines the only AST shapes the parser produces | KR-1 | was `KRLAdapter.jl/src/parser/ast.jl` — gone. `quandledb/server/krl/Ast.jl` exists but encodes a *different* language (see below) |
| A-KR-2.1 | DESIGN | **UNANCHORED** | Generator arity is fixed: `sigma i / sigma_inv i : in=i+1, out=i+1`; `cup i : in=0, out=2`; `cap i : in=2, out=0` | KR-2 | `spec/grammar.ebnf` only. No implementation defines these generators — `sigma`, `cup` and `cap` appear 0 times in `quandledb/server/krl/` |
| A-KR-2.2 | MATH | holds | `arity_in(a \| b) = arity_in(a) + arity_in(b)` and same for output (monoidal-category tensor) | KR-2 | Standard categorical tangle definition |
| A-KR-3.1 | MATH | holds | Reidemeister's theorem: R1+R2+R3 generate isotopy equivalence on tangle diagrams | KR-3 | Reidemeister 1927; Kauffman _Knots and Physics_ ch. 1 |
| A-KR-3.2 | DESIGN | **UNANCHORED** | `r1_simplify` / `r2_simplify` / `r3_simplify` implement those moves faithfully | KR-3 | was `KRLAdapter.jl/src/operations.jl` — gone. No Reidemeister simplification exists in `quandledb/server/krl/` |
| A-KR-4.1 | DESIGN | **UNANCHORED** | The pretty-printer's bracketing is unambiguous: `;` only inside parens; tensor `\|` has lower precedence than compose `;` inside parens | KR-4 | No pretty-printer exists in any current implementation |
| A-KR-6.1 | DESIGN | **VOID** | Two independent parsers both target `spec/grammar.ebnf` v0.1.0 | KR-6 | Only one parser now exists (`quandledb/server/krl/Parser.jl`), and it targets `quandledb/spec/grammar.ebnf`, not this one |
| A-KR-6.2 | DESIGN | **VOID** | Both implementations share the same `Token` enumeration | KR-6 | Only one lexer now exists (`quandledb/server/krl/Lexer.jl`); there is nothing to share with |
| A-KR-8.1 | MATH (partial) | holds | Fundamental-quandle functor is faithful on prime alternating knots; partial in general | KR-8 | Joyce 1982; for partial cases see Eisermann _The number of knot group representations_ |
| A-KR-8.2 | MATH | holds | Two non-isomorphic quandles have distinct canonical presentations (true by definition of "canonical") | KR-8 | Standard algebraic-presentation result |

### On the UNANCHORED and VOID rows

A DESIGN assumption is defined above as *"true by construction in our code
(must remain true; flag if you change the named code)"*. Seven rows named code
in `KRLAdapter.jl`, which no longer exists, so there is no construction left to
be true by. They are recorded here rather than deleted, because the statements
are still the design intent — but none of them is currently checkable, and none
may be cited as discharged.

**UNANCHORED** means the statement stands as intent but names no live code.
**VOID** means the statement presupposes two implementations, and only one
exists.

Re-anchoring is blocked on the specification itself. `spec/grammar.ebnf` (here)
and `quandledb/spec/grammar.ebnf` are disjoint on core vocabulary: the braid
generators these assumptions describe appear only in the former, and only the
latter is implemented. Until the two are reconciled and a conformance suite
exists, these rows cannot be re-anchored to anything. See `READINESS.md`.

---

## How to use this file

- **Reading code.** When you see a function whose correctness depends
  on something not enforced by the local types — _that's an
  assumption_. Find or add the entry here and reference it by ID.
- **Writing a proof.** Every proof obligation in
  [PROOF-NARRATIVE.md](PROOF-NARRATIVE.md) names its assumptions by
  ID. Before discharging the proof, audit the assumptions.
- **Modifying load-bearing code.** Each DESIGN assumption names a
  file. If you edit that file, re-validate the assumption (or update
  the obligation if you changed the design intentionally).

## Promoting / demoting assumptions

| From | To | Trigger |
|------|-----|---------|
| EMPIRICAL → MATH | discharge with a citation |
| EMPIRICAL → DESIGN | refactor to make it a structural invariant |
| MATH → (delete) | obligation it supports has been re-cast not to need it |
| DESIGN → MATH (rare) | the design happens to encode a known theorem |
| any → CRYPTO | only for cryptographic primitives (BLAKE3, SHA-256, etc.) |

When you change a row, leave a one-line note at the bottom of this
file with the date and reason.

---

## Changelog

| Date | Change | By |
|------|--------|-----|
| 2026-06-01 | Initial registry, scoped to KRL surface obligations | Audit |
| 2026-07-21 | Added Status column. Marked A-KR-1.1, 1.2, 2.1, 3.2 and 4.1 UNANCHORED and A-KR-6.1, 6.2 VOID: all seven named code in `KRLAdapter.jl`, which no longer exists. Verified that no replacement exists — `sigma`, `cup`, `cap`, `r1_simplify` and any pretty-printer appear 0 times in `quandledb/server/krl/`. The four MATH rows are unaffected. | Audit |
