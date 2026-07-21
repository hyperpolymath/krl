<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
<!-- Last updated: 2026-07-21 -->

# Architecture Topology — KRL

## System overview

KRL is the resolution language for QuandleDB, a knot database. This repository
holds the **specification** and the **ABI surface**; the parser and evaluator
live in QuandleDB. That split is the single most important fact about this
repository's topology, and it is the source of most of its current problems.

## Project boundaries

| Project | Repository | Relationship to KRL |
|---|---|---|
| QuandleDB | `hyperpolymath/quandledb` | Hosts the KRL implementation (`server/krl/`) and the database KRL addresses. Developed jointly with KRL. |
| KRL | `hyperpolymath/krl` (this repo) | Normative specification, Idris2 ABI, Zig FFI, examples. |
| Tangle | `hyperpolymath/tangle` | **Separate project.** A general language for knot mathematics. Shares the subject matter; there is no compilation or dependency relationship in either direction. |

There is no `KRL → TangleIR → Tangle` pipeline. Earlier documentation in both
this repository and `tangle` described one; it does not exist, and `TangleIR`
appears nowhere in the KRL implementation.

## Component overview

| Component | Language | Location | Purpose |
|---|---|---|---|
| Grammar specification | EBNF | `spec/grammar.ebnf` | Normative surface syntax (contested — see below) |
| ABI declarations | Idris2 | `src/interface/Abi/` | 4 `%foreign` declarations; types and memory layout |
| FFI shim | Zig | `src/interface/ffi/` | 11 `export fn` over the C ABI; builds `libkrl.a` |
| Examples | KRL | `examples/*.krl` | 4 programs, lexically checked against the grammar |
| Smoke suite | Bash | `tests/smoke/grammar_smoke.sh` | 20 lexical conformance checks |
| Parser / evaluator | Julia | `quandledb/server/krl/` — **not here** | Lexer, parser, AST, evaluator, SQL front end |

## The spec/implementation seam

```
  spec/grammar.ebnf  ──(normative, 114 lines, braid algebra)
        │
        ✗  no conformance suite — nothing checks this link
        │
  quandledb/spec/grammar.ebnf ──(402 lines, pipeline syntax)
        │
        └──> quandledb/server/krl/  (3,035 lines Julia + 1,732 lines tests)
```

The two grammar documents are disjoint on core vocabulary, and `|` is bound to
opposite meanings in them — tensor product here, pipeline separator there. Only
the second is implemented. Closing this seam with a reconciled specification and
an executable conformance suite is the primary outstanding work; see
`READINESS.md`.

## ABI/FFI layering

```
  Idris2  src/interface/Abi/{Types,Layout,Foreign}.idr
            │  %foreign declarations (4)
            ▼
  C ABI   ─────────────────────────────────────────
            ▲
            │  export fn (11)
  Zig     src/interface/ffi/src/main.zig  ──>  libkrl.a
```

`tests/aspect_tests.sh` enforces that every `%foreign` declaration is covered by
a Zig export.

## Integration points

- **Upstream:** `hyperpolymath/standards` (shared reusable workflows, CRG),
  Hypatia (neurosymbolic CI scan), eclexiaiser (resource scoring).
- **Downstream:** QuandleDB consumes the specification. Nothing else depends on
  this repository.

## Deployment

This repository ships no runtime service. Its outputs are the specification,
`libkrl.a`, and the published documentation site (Ddraig SSG → GitHub Pages).

- CI/CD: GitHub Actions — E2E/aspect/smoke/FFI gates, governance, secret
  scanning, CodeQL, Hypatia.
- Service discovery: **none**. There is no
  `.well-known/groove/manifest.json`, because this repository exposes no
  service. The `groove-check` job treats absence as a pass for exactly this
  case. `.well-known/` carries `security.txt`, `humans.txt` and `ai.txt` only.
