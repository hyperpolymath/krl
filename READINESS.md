<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# Component Readiness — KRL

**Standard:** [CRG v2.0 STRICT](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)
**Current Grade:** X
**Assessed:** 2026-04-05
**Assessor:** Jonathan D.A. Jewell

---

## Grade rationale (evidence for X)

**Untested — default state.** Repository was scaffolded from rsr-template-repo
on 2026-04-05. No KRL-specific content beyond the template placeholders exists yet.

Template default of "C" was overridden to X per CRG v2 STRICT honesty rule:
"Grade as-is TODAY, not aspirational — honest D > dishonest B".

### What exists

- RSR template infrastructure (workflows, SECURITY/CONTRIBUTING/CODE_OF_CONDUCT, `.machine_readable/6a2/` skeleton)
- 0-AI-MANIFEST.a2ml
- Template-provided directory structure

### What does not yet exist

- KRL grammar (EBNF/PEG)
- Parser, AST, typechecker, compiler
- Surface-syntax examples
- KRL-specific test suite
- Language reference documentation

---

## Path to E (pre-alpha)

1. Draft KRL EBNF/PEG grammar with `construct`, `transform`, `resolve`, `retrieve`
   operation families + compositional syntax (`;`, `|`, `close`, `let`, `find`).
2. Add at least 1 test — smoke test that parses a "hello tangle" KRL source.
3. Document known failures / incomplete grammar branches.

## Path to D (alpha)

After E: AST + typechecker + rudimentary compiler to TangleIR (via KRLAdapter.jl)
+ test matrix across parse/typecheck/compile stages.

## Path to C (alpha-stable)

After D: deep annotation, per-directory orientation, reliable dogfooding
(compile several real KRL programs into stored Skein records).

## Path to B (beta)

After C: 6+ diverse external targets tested, issues fed back.

---

## Review cycle

Reassess on first grammar draft and on each implementation milestone.

---

## Run `just crg-badge` to generate the shields.io badge for your README.
