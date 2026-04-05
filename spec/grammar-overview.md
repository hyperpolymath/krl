<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# KRL Grammar Overview — v0.1.0

**Status:** DRAFT. Grammar drafted 2026-04-05. No parser yet; this document plus `grammar.ebnf` are the only artefacts.

KRL (pronounced "curl") is the Knot Resolution Language — a compositional DSL
for constructing, transforming, resolving, and retrieving topological objects
(tangles, knots, links).

## The four operation families

KRL's syntax is designed around four verbs that together span every
interaction with the system:

| Family | Operations | Grammar production |
|---|---|---|
| **CONSTRUCT** | build tangles from generators | `generator`, `compose_expr`, `tensor_expr` |
| **TRANSFORM** | Reidemeister moves, mirror, simplify, normalise | `prefix_op` |
| **RESOLVE** | closure, equivalence, classification | `"close"`, `"classify"` |
| **RETRIEVE** | query by invariant | `query`, `filter` |

## Minimal example

```krl
-- Construct the trefoil as three positive crossings in sequence
let trefoil = close (sigma 1 ; sigma 1 ; sigma 1) ;

-- Transform by mirror
let mirror_trefoil = mirror trefoil ;

-- Retrieve by invariant
find where jones = trefoil and crossing < 8 ;
```

## Operator precedence

From weakest to strongest binding:

1. `;` — sequential composition (left-associative)
2. `|` — tensor product (left-associative)
3. prefix operators (`close`, `mirror`, `simplify`, `normalise`, `classify`)
4. atoms: generators, identifiers, parenthesised expressions

So `mirror sigma 1 ; sigma 2` parses as `(mirror (sigma 1)) ; (sigma 2)`.

## Reserved words

```
let  close  mirror  simplify  normalise  classify
find  where  and
sigma  sigma_inv  cup  cap
```

## Comments

Line comments start with `--` and extend to end of line.

## Known gaps (documented failures — honest for grade E)

1. **No parser.** The grammar is written, not implemented. Path to D is
   "grammar → AST → typechecker → compiler to TangleIR (via KRLAdapter.jl)".
2. **Equivalence predicates (`equivalent?`, `near`) not yet in grammar.**
   Placeholder comment in EBNF; will be added in v0.2.
3. **No polymorphic generators.** Only `sigma N`, `sigma_inv N`, `cup N`, `cap N`
   are defined. No way yet to parameterise by strand count.
4. **No type annotations.** Type safety is by port-arity checking at compile
   time; not surface syntax. Will interact with TypeLL integration later.
5. **No import mechanism.** Multi-file programs not yet supported.
6. **No error-location reporting.** No parser means no error messages.

## Target implementation language for v0.2 parser

**Option A (current lean):** write parser in Tangle (OCaml-embedded). Dogfoods
Tangle as the host language for KRL, but requires bootstrap work.

**Option B:** write parser in Julia inside `KRLAdapter.jl`. Fastest path to a
working parser; loses the host-language dogfooding story.

**Option C:** write parser in OCaml as a sibling to tangle's compiler,
sharing lexer/parser infrastructure.

Decision deferred until KRL passes D grade validation.

## See also

- `grammar.ebnf` — the formal grammar
- `../examples/` — example KRL programs
- `../tests/smoke/` — grammar smoke tests
- `../EXPLAINME.adoc` — honest scope of the krl repository
