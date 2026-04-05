<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# Component Readiness — KRL

**Standard:** [CRG v2.0 STRICT](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)
**Current Grade:** E
**Assessed:** 2026-04-05 (promoted X → E after iteration 1)
**Assessor:** Jonathan D.A. Jewell

---

## Grade rationale (evidence for E — promoted from X)

Grade E criterion: "At least 1 test, documented failures."

### Evidence

- **Grammar drafted:** `spec/grammar.ebnf` v0.1.0 — EBNF for all four KRL
  operation families (CONSTRUCT / TRANSFORM / RESOLVE / RETRIEVE)
- **Grammar overview:** `spec/grammar-overview.md` — prose introduction,
  operator precedence, reserved words, known gaps
- **Examples:** 4 runnable examples covering all 4 operation families
  - `examples/trefoil.krl` — CONSTRUCT + RESOLVE + TRANSFORM
  - `examples/figure_eight.krl` — CONSTRUCT + TRANSFORM
  - `examples/query-by-jones.krl` — CONSTRUCT + RESOLVE + RETRIEVE
  - `examples/tensor-and-close.krl` — CONSTRUCT with tensor + closure
- **Smoke test:** `tests/smoke/grammar_smoke.sh` — 16 lexical checks against
  the examples, all passing. Validates terminator presence, paren balance,
  generator-argument shape, operation-family coverage.
- **RSR compliance:** inherited from rsr-template-repo scaffold

### What was tested (16 assertions)

Per .krl example file:
- Statement terminators (`;`) present
- Parentheses balanced
- No v0.2-reserved tokens (equivalent?, near, classify_by, prove) used prematurely
- At least one operation family exercised

### What is NOT tested (honest — documented failures)

- **No parser.** The grammar is declared, not implemented. None of the
  examples have been parsed by code.
- **No AST.** Nothing reads a .krl file into a structured form.
- **No typechecker.** Port-arity compatibility not verified.
- **No TangleIR compilation.** No path from .krl source to
  KRLAdapter.TangleIR yet.
- **No error messages.** Absence of parser means absence of diagnostics.

---

## Path to D (alpha, test matrix + RSR)

1. Choose parser implementation language (tangle OCaml host, KRLAdapter
   Julia, or sibling OCaml compiler — see `spec/grammar-overview.md`).
2. Implement lexer + parser for v0.1.0 grammar.
3. Define AST in chosen language.
4. Add test matrix: parse tests (one per example), parse-fail tests (one
   per malformed input), roundtrip tests (AST → pretty-print → parse).
5. Scope documentation in this file: what KRL programs parse, what KRL
   programs don't yet.

## Path to C (alpha-stable)

After D: typechecker (port-arity + generator index validity), compiler
to TangleIR via KRLAdapter.jl, deep annotation per-directory, real
dogfooding by parsing 20+ KRL programs representing knots from the
knot table.

## Path to B (beta)

After C: 6+ diverse external targets (knot researchers, DSL authors,
topology educators) write KRL programs and report back.

---

## Iteration history

### Iteration 0 (X grade — 2026-04-05 initial scaffold)
Templated from rsr-template-repo. Zero KRL-specific content.

### Iteration 1 (promoted to E — 2026-04-05)
- spec/grammar.ebnf (v0.1.0 EBNF)
- spec/grammar-overview.md
- 4 examples/ programs
- tests/smoke/grammar_smoke.sh (16 lexical assertions, all passing)

## Review cycle

Reassess on first parser implementation milestone, or if examples drift
from what the grammar admits.

---

## Run `just crg-badge` to generate the shields.io badge for your README.
