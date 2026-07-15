using Test
using Extinctions
using SpeciesInteractionNetworks

@testset "Robustness & Resilience" begin

    # ------------------------------------------------
    # Simple chain network: wolf -> fox -> rat -> plant
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
    # TEST 1: Interpolation check (Threshold = 50%)
    # =================================================
    # Deleting :plant causes a cascading extinction of ALL species in a chain network.
    # - Before deletion: 0 primary extinctions, 100% (4/4) richness. (x1 = 0.0, y1 = 1.0)
    # - After deleting :plant: 1 primary extinction, 0% (0/4) richness. (x2 = 0.25, y2 = 0.0)
    # - Target: 50% threshold (T = 0.5)
    # Formula: x = 0.0 + (0.5 - 1.0) * (0.25 - 0.0) / (0.0 - 1.0) = 0.125
    @testset "single extinction collapse with interpolation" begin

        r = robustness(
            N;
            extinction_order = [:plant],
            threshold = 50
        )

        @test r ≈ 0.125
    end

    # =================================================
    # TEST 2: Linear sequence (Threshold = 75%)
    # =================================================
    # Let's say we target 75% richness (T = 0.75).
    # - Step 0 (start): x1 = 0.0, y1 = 1.0
    # - Step 1 (plant deleted): x2 = 0.25, y2 = 0.0
    # Formula: x = 0.0 + (0.75 - 1.0) * (0.25 - 0.0) / (0.0 - 1.0) = 0.0625
    @testset "interpolation at 75% threshold" begin

        r = robustness(
            N;
            extinction_order = [:plant],
            threshold = 75
        )

        @test r ≈ 0.0625
    end

    # =================================================
    # TEST 3: Edge Case Thresholds (100% and 0%)
    # =================================================
    @testset "boundary threshold behavior" begin

        order = [:plant, :rat, :fox, :wolf]

        # A 100% threshold means we tolerate ZERO extinctions. 
        # Even before the first step, we are at 100%. 
        # But if any extinction is tested, it should interpolate or return 0.0.
        r_high = robustness(
            N;
            extinction_order = order,
            threshold = 100
        )
        @test r_high ≈ 0.0

        # An extremely low threshold (e.g. 1% or effectively 0% threshold).
        # We delete all 4 species to hit 0 richness.
        # - Step 0: x=0.0, y=1.0
        # - Step 1 (delete plant): chain collapses, x=0.25, y=0.0 (below 1% threshold).
        # Interpolating target T = 0.01:
        # x = 0.0 + (0.01 - 1.0) * (0.25 - 0.0) / (0.0 - 1.0) = 0.2475
        r_low = robustness(
            N;
            extinction_order = order,
            threshold = 1
        )
        @test r_low ≈ 0.2475
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
    # - Before: 0 extinctions, 100% richness (x1 = 0.0, y1 = 1.0)
    # - After: 1 primary extinction, 0% richness (x2 = 1.0, y2 = 0.0)
    # - Target: 50% (T = 0.5)
    # Formula: x = 0.0 + (0.5 - 1.0) * (1.0 - 0.0) / (0.0 - 1.0) = 0.5
    @testset "single species network" begin

        spp1 = [:plant]
        nodes1 = Unipartite(spp1)
        edges1 = Binary(zeros(Bool, 1, 1))
        N1 = SpeciesInteractionNetwork(nodes1, edges1)

        r = robustness(N1; extinction_order = [:plant], threshold = 50)

        @test r ≈ 0.5
    end

    # =================================================
    # TEST 6: output validity bounds
    # =================================================
    @testset "valid output range" begin

        r = robustness(N; extinction_order = [:plant], threshold = 50)

        @test 0.0 <= r <= 1.0
    end

    # =================================================
    # TEST 7: Step-by-step gradual interpolation
    # =================================================
    @testset "gradual extinction interpolation" begin
        # Removing from the top of the chain (wolf -> fox -> rat -> plant)
        # prevents secondary cascades, resulting in a perfect step-by-step decline.
        gradual_order = [:wolf, :fox, :rat, :plant]

        # Target 60% richness (should interpolate between 75% and 50% richness)
        # Expected value: 0.40 (or 40% primary extinctions)
        r_60 = robustness(
            N;
            extinction_order = gradual_order,
            threshold = 60
        )
        @test r_60 ≈ 0.40

        # Target 40% richness (should interpolate between 50% and 25% richness)
        # Expected value: 0.60 (or 60% primary extinctions)
        r_40 = robustness(
            N;
            extinction_order = gradual_order,
            threshold = 40
        )
        @test r_40 ≈ 0.60
    end
    
end