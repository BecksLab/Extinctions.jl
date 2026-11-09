using Test
using Extinctions
using SpeciesInteractionNetworks

@testset "Extinctions" begin

    @testset "Extinction Sequence" begin
        include("units/00_allgood.jl")
    end

    @testset "Cascade" begin
        include("units/01_cascade.jl")
    end

    @testset "Numeric" begin
        include("units/02_numeric.jl")
    end

    @testset "Robustness & Resilience" begin
        include("units/03_robustness.jl")
    end

    @testset "Core Behavior" begin
        include("units/04_core_behavior.jl")
    end

end