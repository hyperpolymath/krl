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

| ID | Class | Statement | Cited by | Where it lives |
|----|-------|-----------|----------|----------------|
| A-KR-1.1 | DESIGN | Every `KRLExpr` AST variant has a matching arm in `KRLAdapter.jl::lower.jl` | KR-1 | `KRLAdapter.jl/src/parser/lower.jl` |
| A-KR-1.2 | DESIGN | `KRLAdapter.jl/src/parser/ast.jl` defines the only AST shapes the parser produces | KR-1 | `KRLAdapter.jl/src/parser/ast.jl` + `parser.jl` |
| A-KR-2.1 | DESIGN | Generator arity is fixed: `sigma i / sigma_inv i : in=i+1, out=i+1`; `cup i : in=0, out=2`; `cap i : in=2, out=0` | KR-2 | KRL grammar definitions; `KRLAdapter.jl/src/operations.jl` |
| A-KR-2.2 | MATH | `arity_in(a \| b) = arity_in(a) + arity_in(b)` and same for output (monoidal-category tensor) | KR-2 | Standard categorical tangle definition |
| A-KR-3.1 | MATH | Reidemeister's theorem: R1+R2+R3 generate isotopy equivalence on tangle diagrams | KR-3 | Reidemeister 1927; Kauffman _Knots and Physics_ ch. 1 |
| A-KR-3.2 | DESIGN | `KRLAdapter.jl::r1_simplify` / `r2_simplify` / `r3_simplify` implement those moves faithfully (R3 is a current GAP — see `quandledb/PROOF-NARRATIVE.md` QD-2) | KR-3 | `KRLAdapter.jl/src/operations.jl` |
| A-KR-4.1 | DESIGN | KRL pretty-printer's bracketing is unambiguous: `;` only inside parens; tensor `\|` has lower precedence than compose `;` inside parens | KR-4 | `KRLAdapter.jl` pretty; `spec/grammar.ebnf` |
| A-KR-6.1 | DESIGN | `KRLAdapter.jl::parse_krl` and `quandledb/server/krl/Parser.jl::parse_any` both target `spec/grammar.ebnf` v0.1.0 | KR-6 | `spec/grammar.ebnf` |
| A-KR-6.2 | DESIGN | Both implementations share the same `Token` enumeration: keyword set, identifier shape, integer/string literal shapes | KR-6 | `KRLAdapter.jl/src/parser/lexer.jl` and `quandledb/server/krl/Lexer.jl` |
| A-KR-8.1 | MATH (partial) | Fundamental-quandle functor is faithful on prime alternating knots; partial in general | KR-8 | Joyce 1982; for partial cases see Eisermann _The number of knot group representations_ |
| A-KR-8.2 | MATH | Two non-isomorphic quandles have distinct canonical presentations (true by definition of "canonical") | KR-8 | Standard algebraic-presentation result |

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
