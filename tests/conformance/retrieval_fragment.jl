# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
using Test
length(ARGS) == 1 || error("Usage: julia retrieval_fragment.jl /path/to/quandledb")
implementation = joinpath(abspath(ARGS[1]), "server", "krl", "KRL.jl")
isfile(implementation) || error("QuandleDB KRL implementation not found: $implementation")
include(implementation)
using .KRL

struct FragmentData <: KRL.DataProvider end
struct FragmentIndex <: KRL.SemProvider end
KRL.fetch_all(::FragmentData; kwargs...) = [
    Dict{String,Any}("name" => "3_1", "crossing_number" => 3),
    Dict{String,Any}("name" => "5_1", "crossing_number" => 5)]
KRL.equiv_buckets(::FragmentIndex, ::String) =
    (strong=["3_1"], weak=["3_1", "5_1"])
execute(source) = KRL.eval_krl_program(parse_krl(source),
    KRL.make_eval_context(FragmentData(), FragmentIndex()))

@testset "KRL retrieval fragment contract" begin
    q = parse_krl_query("from knots | filter crossing_number == 3 | return name")
    @test q.source isa KRLSourceKnots
    @test q.stages[1] isa KRLFilterStage
    @test q.stages[2] isa KRLReturnStage
    resolution = parse_krl_query("from knots | find_equivalent \"3_1\" confidence >= exact")
    @test resolution.stages[1] isa KRLFindEquivStage
    @test resolution.stages[1].min_confidence == ConfExact
    # Syntax acceptance is distinct from the evaluator's assurance refusal.
    for invalid in ["from knots | filter", "from knots | wobble 3",
                    "from knots | take x", "from (from knots",
                    "sigma 1;", "let k = close (sigma 1 | sigma 2);",
                    "rule is_small(k) :- crossing_number(k) <= 6",
                    "axiom reflexivity : x == x -> true",
                    "from knots | find_path \"3_1\" ~> \"3_1\" via reidemeister",
                    "from knots | match (k)"]
        @test_throws KRLParseError parse_krl(invalid)
    end
end

@testset "KRL execution and refusal contract" begin
    selected = execute("from knots | filter crossing_number == 3 | return name")
    @test getindex.(selected.rows, "name") == ["3_1"]
    candidates = execute("from knots | find_equivalent \"3_1\"")
    @test length(candidates.rows) == 2
    @test all(row -> row["_equiv_confidence"] == "ConfHeuristic", candidates.rows)
    @test any(w -> occursin("candidate", w), candidates.warnings)
    @test !haskey(only(filter(row -> row["name"] == "5_1", candidates.rows)), "_equiv_class")
    for level in ["exact", "sufficient", "necessary"]
        @test_throws KRL.KRLEvalError execute(
            "from knots | find_equivalent \"3_1\" confidence >= " * level)
    end
    @test isempty(execute(
        "from knots | filter crossing_number > 100 | find_equivalent \"3_1\"").rows)
end
