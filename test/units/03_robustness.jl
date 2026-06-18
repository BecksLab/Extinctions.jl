using Test
using Extinctions
using SpeciesInteractionNetworks

@testset "Robustness & Resilience" begin

    # ------------------------------------------------
    # Simple chain network
    # ------------------------------------------------
    spp = [:wolf, :fox, :rat, :plant]
    nodes = Unipartite(spp)

    int_matrix = Bool[
        0 1 0 0
        0 0 1 0
        0 0 0 1
        0 0 0 0
    ]

    edges = Binary(int_matrix)
    N = SpeciesInteractionNetwork(nodes, edges)

    # =================================================
    # TEST 1: deterministic robustness (single extinction)
    # =================================================
    @testset "single extinction collapse" begin

        r = robustness(
            N;
            extinction_order = [:plant]
        )

        # Only 1 removal needed out of 4 species → collapse immediately
        @test r == 0.0
    end

    # =================================================
    # TEST 2: full extinction order
    # =================================================
    @testset "full extinction order" begin

        r = robustness(
            N;
            extinction_order = [:plant, :rat, :fox, :wolf]
        )

        @test r == 0.0
    end

    # =================================================
    # TEST 3: threshold edge cases
    # =================================================
    @testset "threshold behaviour" begin

        order = [:plant, :rat, :fox, :wolf]

        r_high = robustness(
            N;
            extinction_order = order,
            threshold = 100
        )

        @test r_high == 0.0

        r_low = robustness(
            N;
            extinction_order = order,
            threshold = 1
        )

        @test r_low == 0.0
    end

    # =================================================
    # TEST 4: invalid mechanism should error
    # =================================================
    @testset "invalid inputs" begin

        @test_throws ErrorException robustness(
            N;
            mechanism = :invalid
        )
    end

    # =================================================
    # TEST 5: single species network edge case
    # =================================================
    @testset "single species network" begin

        spp1 = [:plant]
        nodes1 = Unipartite(spp1)
        edges1 = Binary(zeros(Bool, 1, 1))
        N1 = SpeciesInteractionNetwork(nodes1, edges1)

        r = robustness(N1; extinction_order = [:plant])

        @test r == 0.0
    end

    # =================================================
    # TEST 6: output validity bounds
    # =================================================
    @testset "valid output range" begin

        r = robustness(N; extinction_order = [:plant])

        @test 0.0 <= r <= 1.0
    end

end