<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

# KRL — Knot Resolution Language

[![OpenSSF Best Practices](https://img.shields.io/badge/OpenSSF-Best_Practices-green?logo=opensourcesecurity)](https://www.bestpractices.dev/en/projects/new?repo_url=https://github.com/hyperpolymath/krl)

KRL (pronounced "curl") is the resolution language for
[QuandleDB](https://github.com/hyperpolymath/quandledb). This repository holds
its **normative specification**; the implementation lives in QuandleDB.

## What it is

QuandleDB is a **knot database** — a database whose stored objects are knots and
tangles, and whose identity relation is equivalence under ambient isotopy rather
than byte equality. KRL is the language you use to work with it.

The point of a dedicated language is that the interesting questions about a knot
database are hard ones — is this the same knot, what class does it fall in, what
witnesses the answer — and you should be able to ask them directly rather than
assembling them out of general-purpose data access. Record retrieval is one
operation *within* KRL, because without it you could not get at anything; it is
not what KRL is for.

The name reflects the central operation. In knot theory, *resolution* is how
crossings are resolved in the skein relation — the algebraic heart of invariant
computation. KRL generalises the word to every interaction with the system:
resolving structure, resolving equivalence, resolving queries.

## Where KRL sits

Three separate projects, developed for different purposes:

| Project | What it is |
|---|---|
| [**QuandleDB**](https://github.com/hyperpolymath/quandledb) | The knot database. Stores presentations, invariants, fingerprints, equivalence classes and witnesses. |
| **KRL** (this repository) | QuandleDB's resolution language. Specified here, implemented in `quandledb/server/krl/`. |
| [**Tangle**](https://github.com/hyperpolymath/tangle) | A separate, general language for knot mathematics — topological, algebraic, geometric and logical. Turing-complete; not a backend for KRL. |

KRL and QuandleDB were designed together and are deliberately close. Tangle is a
different project with a different remit that happens to share the subject
matter. The two are related by domain, not by architecture: **KRL does not
compile to, lower into, or depend on Tangle.**

> [!IMPORTANT]
> Earlier revisions of this README described a `KRL → TangleIR → Tangle`
> compilation pipeline and named `KRLAdapter.jl` as the canonical
> implementation. Neither is true. `TangleIR` does not appear anywhere in the
> KRL implementation, and `KRLAdapter.jl` no longer exists. Those claims have
> been removed rather than restated.

## The four operations

KRL has four operation families. The four-verb shape is deliberate: it stops
"querying" from becoming the whole identity of the language.

| Operation | Knot concept | What it does |
|---|---|---|
| **construct** | Tangles, ports, composition, tensor | create or declare presentations, structures, claims, datasets |
| **transform** | PD code, Reidemeister moves | rewrite, normalise, compose, concatenate, permute, mutate |
| **resolve** | Isotopy, quandle, equivalence class | decide, disambiguate, or evaluate equivalence and identity questions |
| **retrieve** | Invariants, witnesses, stored resolutions | inspect, fetch, project, explain, or return stored or computed results |

> [!NOTE]
> **Retrieve is not arbitrary database querying.** It recovers
> resolution-relevant artefacts: presentations, invariants, witnesses,
> equivalence classes, prior resolutions, explanations and provenance.
>
> Generic data access — arbitrary filters, dashboards, reporting, analytics,
> index tuning — is an engine-layer affordance, deliberately not elevated to a
> KRL operation. A separate query language is **deferred**, not absent; see
> `docs/decisions/0002-query-language-deferred.adoc`.

## What this repository holds

- The grammar specification (`spec/grammar.ebnf`).
- Idris2 ABI declarations (`src/interface/Abi/`).
- A Zig FFI shim over the C ABI (`src/interface/ffi/`).
- Example programs (`examples/*.krl`).
- The proof narrative (`PROOF-NARRATIVE.md`) and obligations registry.

It does **not** hold a parser or evaluator. Those are in
`quandledb/server/krl/` — 3,035 lines of Julia (lexer, parser, AST, evaluator,
SQL front end) with 1,732 lines of tests.

## Status

Assessed against what is in this tree, not against absent work.

| Component | State |
|---|---|
| Grammar specification | Drafted (`spec/grammar.ebnf`, 114 lines) |
| Examples | Four `.krl` programs, lexically checked against the grammar by `tests/smoke/grammar_smoke.sh` (20 checks) |
| Idris2 ABI | Declared — 4 `%foreign` declarations |
| Zig FFI | Compiles; 3/3 unit tests pass; `zig build` produces `libkrl.a` |
| Parser / evaluator | Not in this repository (see above) |
| Conformance suite | Not yet written — planned, see below |

There is no parser here, so nothing in this repository can execute a KRL
program. `tests/smoke/grammar_smoke.sh` performs lexical-level checking only and
says so.

## Known divergence

Two documents currently call themselves the KRL grammar, and they do not agree:

| | `krl/spec/grammar.ebnf` | `quandledb/spec/grammar.ebnf` |
|---|---|---|
| Size | 114 lines | 402 lines |
| Construction | `sigma`, `sigma_inv`, `cup`, `cap` | none |
| Retrieval | `find … where …` | `from … \| filter \| sort \| …` pipeline |
| Implemented | no | yes |

They are disjoint on core vocabulary, and `|` is bound to **opposite meanings**
in the two — tensor product here, pipeline separator there. Reconciling them,
and giving this repository an executable conformance suite so that "the spec"
becomes a thing an implementation can be tested against, is the next body of
work. It is not done, and this README does not claim otherwise.

## Related

- [QuandleDB](https://github.com/hyperpolymath/quandledb) — the knot database
- [Tangle](https://github.com/hyperpolymath/tangle) — general knot-mathematics language (separate project)
- [KRL architecture map (HTML)](docs/krl_map.html)
