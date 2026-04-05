# KRL — OpenLearn Course

An OpenLearn-style free course introducing the KRL stack: what it is, why it
exists, and how to use it.

## Status

**Scaffold.** Directory structure is in place. Content is pending.

## Intended audience

- Mathematicians new to computational knot theory
- Programmers curious about domain-specific query languages grounded in algebra
- Open University OpenLearn browsers looking for a worked example of
  formal/algebraic DSL design

## Intended scope

### Module 0 — Why "Resolution"?
Knot theory's skein relations, how resolution is the central operation,
why "query" would undersell it.

### Module 1 — Tangles and TangleIR
Open tangles, closed tangles, ports, crossings, PD codes, composition.
Introduce TangleIR as the canonical interchange object.

### Module 2 — The KRL Stack
Stack layers: KRL surface → TanglePL → TangleIR → Skein.jl + KnotTheory.jl
via KRLAdapter.jl → QuandleDB semantic fingerprints.

### Module 3 — Constructing Knots in KRL
Walkthrough: trefoil, figure-eight. Running a KRL program through the stack.

### Module 4 — Transforming (Reidemeister)
R1, R2, R3 moves. Simplification. Isotopy invariants.

### Module 5 — Resolving (Equivalence)
Quandle presentations. Fundamental quandle as a functor. Colouring counts.

### Module 6 — Retrieving (Query + Persistence)
Skein.jl as the store; query by invariant.

### Module 7 — Where KRL Fits in the Verisim Framework (optional advanced)
Octadic structure, observation functors, KRL as a resolution system.

### Module 8 — Towards Types (advanced)
Tropical types, Katagoria/TypeLL integration. (Requires user's notes to be
written first.)

## Directory layout

```
openlearn/
├── README.md            (this file)
├── modules/             (module content — markdown/adoc/notebook)
├── exercises/           (interactive exercises, worksheets)
└── references/          (bibliography, links, pre-reqs)
```

## Prerequisites (candidates for pre-reqs / "If you already know..." boxes)

- Basic linear algebra
- Undergraduate abstract algebra (groups, modules — not strictly required)
- Ability to read Julia or follow pseudocode
- No prior knot theory required (covered from scratch)

## Target duration

~8–12 hours of study (typical OpenLearn course length).

## Contribution notes

Each module should include:
1. Learning outcomes (3–5 bullet points)
2. Narrative explanation with diagrams (SVG preferred)
3. Interactive exercises that can run in the KRL playground
4. "Reflection" prompt at the end
5. References to further reading

Modules 7 and 8 are blocked on the user's own notes crystallising
(Verisim octadic framework, Katagoria, TypeLL, tropical types).
