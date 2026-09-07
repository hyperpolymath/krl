# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
using Test
length(ARGS) == 1 || error("Usage: julia retrieval_fragment.jl /path/to/quandledb")
implementation = joinpath(abspath(ARGS[1]), "server", "krl", "KRL.jl")
isfile(implementation) || error("QuandleDB KRL implementation not found: $implementation")
include(implementation)
using .KRL

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
                    "sigma 1;", "let k = close (sigma 1 | sigma 2);"]
        @test_throws KRLParseError parse_krl(invalid)
    end
end
