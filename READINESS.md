<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# Component Readiness — KRL

**Standard:** [CRG v2.0 STRICT](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)
**Current Grade:** D
**Assessed:** 2026-04-12 (promoted E → D after iteration 2)
**Assessor:** Jonathan D.A. Jewell

---

## Grade rationale (evidence for D — promoted from E)

Grade D criterion: "Works on some inputs, test matrix present."

### Evidence

- **Parser implemented:** `KRLAdapter.jl/src/parser/` (Julia, Option B decision 2026-04-12)
  - `lexer.jl` — full lexer with position tracking, `KRLLexError`
  - `ast.jl` — all AST node types (`KRLProgram`, `KRLBinding`, `KRLGenerator`,
    `KRLCompose`, `KRLTensor`, `KRLPrefixOp`, `KRLParenExpr`, `KRLIdentifier`,
    `KRLQuery`, `KRLFilter`, `KRLIntValue`, `KRLStrValue`, `KRLIdentValue`)
  - `parser.jl` — recursive descent, full v0.1.0 grammar
  - `lower.jl` — AST → TangleIR lowering with `KRLLowerError`
- **Grammar ambiguity resolved:** `;` as sequential composition only fires
  inside parenthesised expressions (`in_parens=true`); at statement level `;`
  is the terminator.
- **Test matrix:** `KRLAdapter.jl/test/parser_test.jl` — 5 testsets, 57 tests
  - Lexer: keywords, identifiers, integers, strings, operators, punctuation,
    comments stripped, position tracking, lex error, unterminated string
  - Parser: 20 grammar cases including all generators, let bindings, sequential
    compose (with parens), tensor product, prefix ops, queries with `and` chains
  - Parser errors: missing `;`, unrecognised token, missing index, zero index
  - Example .krl files: all 4 examples in `krl/examples/` parse without error
  - Lowering: sigma/sigma_inv → TangleIR, compose, trefoil, mirror, let binding,
    unbound identifier error, query → KRLQueryPlan
- **5577 tests pass** (full KRLAdapter.jl suite including parser tests)

### Grammar coverage

The implemented grammar (v0.1.0):

| Construct | Status |
|-----------|--------|
| `let` binding | ✅ |
| `sigma`, `sigma_inv`, `cup`, `cap` generators | ✅ |
| Sequential composition `(a ; b)` | ✅ |
| Tensor product `a \| b` | ✅ |
| `close`, `mirror`, `simplify`, `normalise`, `classify` | ✅ |
| `find where` queries with `and` | ✅ |
| Parenthesised sub-expressions | ✅ |
| Identifier references (let-bound) | ✅ |
| Line comments `--` | ✅ |
| String, integer, identifier filter values | ✅ |

### What is NOT yet implemented (documented gaps — D grade)

- **No typechecker.** Port-arity compatibility (e.g. composing a 2-strand
  braid with a 3-strand tangle) not verified at parse time.
- **R2 simplification across compose() boundaries.** `simplify_ir` detects
  R2 bigons by arc-index overlap, but `compose()` renumbers arcs so adjacent
  sigma/sigma_inv pairs are not detected. Tracked in `KRLAdapter.jl` issues.
- **No pretty-printer.** `KRLProgram → string` round-trip not yet implemented.
- **No RESOLVE family.** `classify` is parsed and lowered (identity) but
  not dispatched to the query layer.

---

## Grade E rationale (retained for history)

Grade E criterion: "At least 1 test, documented failures."

### Evidence (iteration 1)

- Grammar drafted: `spec/grammar.ebnf`, `spec/grammar-overview.md`
- 4 examples in `examples/`
- Shell smoke test: `tests/smoke/grammar_smoke.sh` (16 lexical assertions)

---

## Path to C (alpha-stable)

After D: typechecker (port-arity + generator index validity), deeper TangleIR
compilation correctness, annotation per-directory, dogfooding by parsing 20+
KRL programs from the knot table. Fix R2 simplification across compose()
boundaries.

## Path to B (beta)

After C: 6+ diverse external targets (knot researchers, DSL authors,
topology educators) write KRL programs and report back.

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

### Iteration 2 (promoted to D — 2026-04-12)
- Decision: Option B — Julia in KRLAdapter.jl
- Implemented: lexer, AST, recursive-descent parser, lowering (KRLAdapter.jl)
- Grammar ambiguity fixed: `;` as compose only inside parentheses
- 57 dedicated parser tests + all 4 example files parse cleanly
- 5577 total KRLAdapter.jl tests pass

## Review cycle

Reassess on typechecker implementation or when 20+ knot-table programs
have been parsed successfully.

---

## Run `just crg-badge` to generate the shields.io badge for your README.
