<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# Component Readiness — KRL

**Standard:** [CRG v2.0 STRICT](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)
**Current Grade:** E
**Assessed:** 2026-07-21 (demoted D → E)
**Assessor:** Jonathan D.A. Jewell

---

## Why the grade moved D → E

The previous assessment (2026-04-12) recorded Grade D on the strength of a
parser, AST, recursive-descent implementation and a 57-test matrix, all of
which lived in `KRLAdapter.jl`. **That repository no longer exists** — it was
discarded, deliberately and not recoverably.

None of the D evidence can be checked. Under the CRG demotion table, `D → E`
applies when *"the scope narrows so far that the component barely does
anything"*, which is precisely what happened: with the adapter gone, nothing in
this repository can parse or execute a KRL program.

This is a correction to the record, not a regression in the work. The grade was
restated rather than left standing on evidence nobody can inspect.

---

## Grade rationale (evidence for E)

Grade E criterion: *"Does something slight … there is a kernel of value … at
least one successful test case demonstrating the kernel of functionality, and
documentation of known failures and limitations."*

Every item below was executed on 2026-07-21, not inferred from documentation.

### Evidence

| Artefact | Check | Result |
|---|---|---|
| `spec/grammar.ebnf` | 114-line EBNF, v0.1.0 | present |
| `examples/*.krl` | 4 example programs | present |
| `tests/smoke/grammar_smoke.sh` | lexical conformance of examples to the grammar | 20 checks, all pass |
| `src/interface/ffi/` | `zig build test` | 3/3 pass |
| `src/interface/ffi/` | `zig build` | produces `libkrl.a` |
| `src/interface/Abi/` | `%foreign` declarations | 4, all covered by 11 Zig exports |
| `tests/aspect_tests.sh` | SPDX, banned constructs, ABI/FFI correspondence | 4/4 pass |
| `tests/e2e.sh` | full local pipeline | 4/4 pass, negative-controlled |

The kernel of value is the specification plus a set of examples that provably
conform to it at the lexical level, over a C ABI that compiles and is tested.

### Known failures and limitations

- **No parser, and therefore no execution.** Nothing in this repository can
  read a `.krl` program and produce a result. `grammar_smoke.sh` is lexical
  only and says so in its own header.
- **The specification is contested.** `spec/grammar.ebnf` here and
  `quandledb/spec/grammar.ebnf` both claim to be KRL v0.1.0 and are disjoint on
  core vocabulary; `|` is bound to opposite meanings in the two. See README.
- **No conformance suite.** There is no executable artefact that an
  implementation can be tested against, so "conforms to the KRL spec" is not
  currently a checkable claim.
- **Proof obligations are unmet.** `PROOF-STATUS.md` records 0 of 8 obligations
  proven, 2 partial.
- **`rust-ci.yml` gates nothing** — it calls the shared Rust reusable, but this
  repository contains no `Cargo.toml`.

---

## Rework needed to reach D

Grade D requires a matrix of tested scenarios and at least one test per claimed
capability. Concretely:

1. **Reconcile the two grammars** into one normative specification, resolving
   the `|` collision.
2. **Write an executable conformance suite** — programs plus expected results —
   so that spec conformance becomes testable rather than asserted.
3. **Run that suite against `quandledb/server/krl/`**, the actual
   implementation (3,035 lines of Julia plus 1,732 lines of tests). One passing
   test per claimed capability is the D bar.

Until at least (1) and (2) exist, this repository specifies a language nobody
can be shown to implement.

---

## Iteration history

### Iteration 0 — X (2026-04-05)
Templated from `rsr-template-repo`. Zero KRL-specific content.

### Iteration 1 — promoted to E (2026-04-05)
- `spec/grammar.ebnf` (v0.1.0 EBNF) and `spec/grammar-overview.md`
- 4 `examples/` programs
- `tests/smoke/grammar_smoke.sh` (16 lexical assertions)

### Iteration 2 — promoted to D (2026-04-12) — **evidence since lost**
Decision "Option B — Julia in `KRLAdapter.jl`"; lexer, AST, recursive-descent
parser and lowering implemented there, with 57 dedicated parser tests. The
repository holding all of it has since been discarded, so none of this is
verifiable. Retained here as history, not as evidence.

### Iteration 3 — demoted to E (2026-07-21)
- Grade restated against what is actually present and runnable in this tree.
- Zig FFI shim repaired: it had never compiled (`opaque` type with fields).
- Three vacuous or false gates repaired (`aspect_tests.sh`, `e2e.sh`).
- False `TangleIR` lowering claims and dead `KRLAdapter.jl` references removed
  from the README.

## Review cycle

Reassess when a conformance suite exists and has been run against
`quandledb/server/krl/`.

---

Run `just crg-badge` to generate the shields.io badge for the README.
