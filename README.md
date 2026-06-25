<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

[![OpenSSF Best Practices](https://img.shields.io/badge/OpenSSF-Best_Practices-green?logo=opensourcesecurity)](https://www.bestpractices.dev/en/projects/new?repo_url=https://github.com/hyperpolymath/krl)

[→ KRL architecture map (HTML)](docs/krl_map.html)

# What it is

KRL (Knot Resolution Language) is QuandleDB’s canonical resolution DSL:
a database-facing language whose domain is knot/tangle identity,
equivalence, transformation, and disambiguation. It is the user- and
author-facing language for constructing, transforming, resolving, and
retrieving knot/tangle presentations, invariants, fingerprints,
equivalence classes, witnesses, and disambiguation results.

The name reflects the central operation: *resolution*. In knot theory,
resolution is how crossings are resolved in the skein relation — the
algebraic heart of invariant computation. KRL extends this to cover
every interaction with the system: resolving structure, resolving
equivalence, resolving queries.

KRL is database-facing but not *merely* a query language. "Query" would
name only one of four operations; "resolution" names the mathematical
act that runs through all of them. Two framings to avoid: "a database
language" alone wrongly suggests SQL-for-knots, and "a surface DSL over
Tangle" alone makes QuandleDB incidental and KRL too compiler-ish. KRL
is precisely QuandleDB’s resolution DSL — it lowers through TangleIR
into Tangle-level computation, with QuandleDB and Skein.jl as its
persistence and computation backends.

# Architecture position

KRL is the surface language of a federated resolution stack. Each layer
answers a distinct question:

<table>
<colgroup>
<col style="width: 20%" />
<col style="width: 80%" />
</colgroup>
<thead>
<tr>
<th><p>Layer</p></th>
<th><p>Role — and the question it answers</p></th>
</tr>
</thead>
<tbody>
<tr>
<td><p><strong>KRL</strong><br />
(this repository)</p></td>
<td><p>User-/author-facing resolution DSL. <em>"What question or claim
are we making about knot-structured identity?"</em> Spec, ABI, FFI
scaffolds; implementations in <code>KRLAdapter.jl</code> (canonical) and
<code>quandledb/server/krl/</code>.</p></td>
</tr>
<tr>
<td><p><strong>TangleIR</strong></p></td>
<td><p>Lowered intermediate representation. <em>"What normalized
computational object represents that resolution task?"</em> Defined in
<code>KRLAdapter.jl</code>, consumed by
<code>hyperpolymath/tangle</code>.</p></td>
</tr>
<tr>
<td><p><strong>Tangle</strong></p></td>
<td><p>Full computational / programming substrate. <em>"What executable
knot-theoretic program or transformation system carries this out?"</em>
Proven type-safe small-step semantics
(<code>hyperpolymath/tangle/proofs/Tangle.lean</code>).</p></td>
</tr>
<tr>
<td><p><strong>QuandleDB</strong></p></td>
<td><p>Persistence + invariant/equivalence database. <em>"Where
presentations, invariants, fingerprints, equivalence classes, witnesses,
and results live."</em> (<code>hyperpolymath/quandledb</code>)</p></td>
</tr>
</tbody><tfoot>
<tr>
<td><p><strong>Skein.jl</strong></p></td>
<td><p>Computational / backend library. <em>"One engine that computes,
transforms, normalizes, or evaluates the objects."</em>
(<code>hyperpolymath/Skein.jl</code>)</p></td>
</tr>
</tfoot>
&#10;</table>

**This repo** is responsible for:

- The KRL grammar specification (`spec/grammar.ebnf`).

- Idris2 ABI types (`src/interface/Abi/`).

- Zig FFI scaffolds (`src/interface/ffi/`).

- Example programs (`examples/`).

- The proof narrative (`PROOF-NARRATIVE.md`) and obligations registry.

The actual KRL parser, lowering, and adapter implementations live in the
companion repos `KRLAdapter.jl` (canonical) and `quandledb/server/krl/`
(server-side query parser — different role). See `PROOF-NARRATIVE.md`
for the two-implementation rationale and the equivalence obligation
`KR-6`.

KRL is **not** responsible for:

- Invariant computation (→ JuliaKnot.jl)

- Persistence (→ Skein.jl)

- Equivalence reasoning (→ QuandleDB)

- Surface-language implementation (→ KRLAdapter.jl)

# The four KRL operations

KRL has exactly four operations. The four-verb shape is deliberate: it
stops "querying" from becoming the whole identity of the language.

**construct**  
create or declare presentations, structures, claims, datasets

**transform**  
rewrite, normalize, compose, concatenate, permute, mutate

**resolve**  
decide / disambiguate / evaluate equivalence or identity questions

**retrieve**  
inspect, fetch, project, explain, or return stored or computed results

<table>
<colgroup>
<col style="width: 16%" />
<col style="width: 33%" />
<col style="width: 16%" />
<col style="width: 33%" />
</colgroup>
<thead>
<tr>
<th><p>Operation</p></th>
<th><p>Knot concept</p></th>
<th><p>Primary site</p></th>
<th><p>Example syntax</p></th>
</tr>
</thead>
<tbody>
<tr>
<td><p><strong>Construct</strong></p></td>
<td><p>Tangles, ports, composition, tensor</p></td>
<td><p>TanglePL</p></td>
<td><p><code>compose</code> <code>sigma1</code>
<code>sigma1</code><br />
<code>tensor</code> <code>a</code> <code>b</code><br />
<code>close</code> <code>t</code></p></td>
</tr>
<tr>
<td><p><strong>Transform</strong></p></td>
<td><p>PD code, Reidemeister moves</p></td>
<td><p>JuliaKnot.jl</p></td>
<td><p><code>simplify</code> <code>t</code><br />
<code>normalise</code> <code>t</code><br />
<code>mirror</code> <code>t</code></p></td>
</tr>
<tr>
<td><p><strong>Resolve</strong></p></td>
<td><p>Isotopy, quandle, equivalence class</p></td>
<td><p>QuandleDB</p></td>
<td><p><code>equivalent?</code> <code>a</code> <code>b</code><br />
<code>classify</code> <code>t</code><br />
<code>near</code> <code>t</code></p></td>
</tr>
</tbody><tfoot>
<tr>
<td><p><strong>Retrieve</strong></p></td>
<td><p>Invariants, witnesses, stored resolutions</p></td>
<td><p>Skein.jl + QuandleDB</p></td>
<td><p><code>find</code> <code>where</code> <code>jones</code>
<code>=</code> <code>p</code><br />
<code>where</code> <code>crossing</code> <code>&lt;</code>
<code>8</code></p></td>
</tr>
</tfoot>
&#10;</table>

> [!NOTE]
> **Retrieve is not arbitrary database querying.** It recovers
> **resolution-relevant artefacts**: presentations, invariants,
> witnesses, equivalence classes, prior resolutions, explanations, and
> provenance.
>
> Generic data access — arbitrary filters, dashboards, reporting,
> analytics, exploratory search, index tuning — is an **engine-layer**
> affordance (Skein.jl predicates over SQLite; QuandleDB’s filtered
> endpoints), deliberately **not** elevated to a KRL operation or a
> rival query language. A separate query language is **deferred**, not
> absent; see `docs/decisions/0002-query-language-deferred.adoc` for the
> rationale and trigger conditions.

# Grammar (sketch)

    expr     ::= atom
               | expr ';' expr          (* sequential composition *)
               | expr '|' expr          (* tensor product *)
               | 'close' expr           (* closure / trace *)
               | 'mirror' expr
               | 'simplify' expr
               | 'let' IDENT '=' expr

    atom     ::= IDENT                  (* named tangle *)
               | generator

    generator ::= 'sigma' INT           (* positive crossing *)
               | 'sigma_inv' INT        (* negative crossing *)
               | 'cup' INT              (* cup on strands i,i+1 *)
               | 'cap' INT              (* cap on strands i,i+1 *)

    query    ::= 'find' 'where' filter ('and' filter)*
    filter   ::= IDENT '=' value
               | IDENT '<' INT
               | IDENT '>' INT

# TangleIR — the canonical interchange

All KRL expressions compile to `TangleIR`. This is the object that flows
between all layers of the stack:

```julia
struct Port
    id::Symbol
    side::Symbol        # :top | :bottom | :left | :right
    index::Int
    orientation::Symbol # :in | :out | :unknown
end

struct CrossingIR
    id::Symbol
    sign::Int           # +1 (positive) | -1 (negative)
    arcs::NTuple{4,Int} # PD-style: (a, b, c, d) arc indices
end

struct TangleMetadata
    name::Union{String,Nothing}
    source_text::Union{String,Nothing}
    tags::Vector{String}
    provenance::Symbol  # :user | :derived | :rewritten | :imported
    extra::Dict{Symbol,Any}
end

struct TangleIR
    id::UUID
    ports_in::Vector{Port}
    ports_out::Vector{Port}
    crossings::Vector{CrossingIR}
    components::Vector{Vector{Int}}  # arc index groups per component
    metadata::TangleMetadata
end
```

`TangleIR` is the single hardest-designed artifact in the stack. Every
other interface is a view over it, a service to it, or a transformation
of it.

# Usage

```julia
using TanglePL, Skein

# parse and compile
ir = compile_tangle("sigma1 ; sigma1 ; sigma1")

# store
db = SkeinDB("knots.db")
id = store!(db, ir; name="trefoil")

# query
candidates = find_equivalence_candidates(db, ir)

# retrieve source
src = reconstruct_source(ir)   # generates valid KRL; not necessarily original
```

# Status

- Grammar: defined (sketch above, formal PEG in progress)

- AST: defined

- Typechecker: boundary arity checking implemented

- Compiler (AST → TangleIR): in development

- Decompiler (IR → source): stub, in progress

- Skein integration: planned

# Related

- <a href="../skein-jl/README.adoc" class="jl">Skein</a> — persistence
  and query

- [QuandleDB](../quandle-db/README.adoc) — semantic fingerprinting

- <a href="../julia-knot/README.adoc" class="jl">JuliaKnot</a> —
  invariant engine

- [Next-generation languages](../nextgen-languages/README.adoc)
