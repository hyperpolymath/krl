<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Test Requirements — KRL

> Implementation-level proofs and their property-test stand-ins are in
> [PROOF-NEEDS.md](PROOF-NEEDS.md). This file is the **test-coverage
> register**: every test that exists, every test that should exist,
> and the CRG grade against `standards/component-readiness-grades`.

## CRG Grade

**Current grade:** D
**Last assessed:** 2026-06-01 (this audit). Promoted E → D 2026-04-12
(see [READINESS.md](READINESS.md)).

D grade criterion: "Works on some inputs, test matrix present."
The test matrix at the spec/grammar/example level is present in this
repo. The actual KRL parser/lower test suite (5577 tests) lives in
the canonical implementation `KRLAdapter.jl`.

## Test inventory

### In this repo

| Path | Kind | What it covers | Status |
|------|------|----------------|--------|
| `tests/smoke/grammar_smoke.sh` | Shell smoke | 16 lexical assertions on grammar tokens | PASSING |
| `tests/aspect_tests.sh` | Shell | Aspect tagging (`src/aspects/`) | PASSING |
| `tests/e2e.sh` | Shell entry-point | Wraps the e2e suite | PASSING |
| `tests/e2e/template_instantiation_test.sh` | Shell E2E | Template instantiation end-to-end | PASSING (template artefact; flag for removal below) |
| `tests/workflows/validate_workflows_test.sh` | Shell | All `.github/workflows/` files have SPDX header + `name:` field | PASSING |
| `src/interface/ffi/test/integration_test.zig` | Zig | Placeholder FFI integration test | PASSING (`placeholder_test_implementation_required`) |
| `benches/template_bench.sh` | Shell | 5 micro-benchmarks (validation, build, tests, workflows, instantiation) | PASSING |

### Out-of-repo (companion suites under proof for this repo's claims)

| Path | Kind | What it covers |
|------|------|----------------|
| `KRLAdapter.jl/test/parser_test.jl` | Julia property | Lexer / parser / lower / 4 example programs (~57 dedicated parser tests) |
| `KRLAdapter.jl/test/*.jl` | Julia | Full KRLAdapter suite (~5577 tests) |
| `quandledb/server/krl/test/*.jl` | Julia | Server-side parser equivalence (lexer / parser / sql / seam — 1713 LoC) |

## Gaps (what we owe)

Cross-referenced to [PROOF-NEEDS.md](PROOF-NEEDS.md) and [PROOF-NARRATIVE.md](PROOF-NARRATIVE.md).

| # | Test gap | Tied to | Effort |
|---|----------|---------|--------|
| TG-K1 | Round-trip property test: `parse(pretty(e)) = e` for every example | KR-4 | 4h |
| TG-K2 | Differential test: `KRLAdapter.jl::parse_krl(s) ≡ quandledb/server/krl::parse_any(s)` on a generated corpus | KR-6 | 4h |
| TG-K3 | Property test: `sigma 0`, `cup 0`, `cap 0` rejected; `sigma N` for `N ≥ 1` accepted | KR-7 | 1h |
| TG-K4 | Property test: lowering exhausts every `KRLExpr` variant (no `KRLLowerError` from un-matched case) | KR-1 / [[A-KR-1.1]] | 2h |
| TG-K5 | Property test: port-arity preservation on every `compose` and `tensor` in `examples/` | KR-2 | 4h |
| TG-K6 | Cross-platform fingerprint test (Linux/macOS/WSL) — coordinate with QuandleDB QD-4 | KR-8 / quandledb QD-4 | 1d |
| TG-K7 | Fuzz harness: random byte-strings → `parse_krl` → assert "either valid AST or `KRLParseError`, never a panic" | KR-1 | 1d |
| TG-K8 | Bench: parse-and-lower throughput vs program size (target: linear) | (perf) | 4h |
| TG-K9 | Bench: round-trip cost (`parse ∘ pretty`) on the example corpus | (perf) | 4h |

## Removed (the template-content cleanup)

The previous `TEST-NEEDS.md` was rsr-template-repo boilerplate
referring to "rsr-template-repo" throughout. Its claimed
**CRG Grade: C — ACHIEVED 2026-04-04** referred to the template
itself, not to KRL. That content has been removed; KRL's actual grade
is D, per [READINESS.md](READINESS.md).

The template-specific test items (template instantiation, workflow
validation count, build-system zig 0.15.2 update, etc.) remain
inventoried above only because their files still exist; they should
be evaluated for removal when KRL gains repo-specific equivalents.

## How to add a new test

1. Add a row to **Test inventory** with path, kind, what-it-covers, status.
2. If it discharges a proof obligation, reference the `KR-N` id and
   note in [PROOF-NARRATIVE.md](PROOF-NARRATIVE.md) under the
   relevant obligation's "How to discharge" line.
3. If new assumptions emerge, register them in [ASSUMPTIONS.md](ASSUMPTIONS.md).

## CRG path forward

- **D → C:** Implement the typechecker (KR-2), discharge KR-1 and KR-4
  as property tests, demonstrate parsing 20+ programs from the knot table.
- **C → B:** 6+ diverse external targets writing KRL programs.
- **B → A:** All P1 obligations in PROOF-NEEDS proven (not just
  property-tested).
