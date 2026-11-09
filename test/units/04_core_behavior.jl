using Extinctions
using SpeciesInteractionNetworks
using Test

@testset "extinction protection and mechanisms" begin
    spp = [:wolf, :fox, :rat, :plant]
    nodes = Unipartite(spp)
    edges = Binary(Bool[
        0 1 0 0
        0 0 1 0
        0 0 0 1
        0 0 0 0
    ])
    network = SpeciesInteractionNetwork(nodes, edges)

    protected = extinction(network, [:plant]; protect = :basal)
    @test length(protected) == 1
    @test species(protected[end]) == spp

    secondary = extinction(
        network,
        [:plant];
        protect = :none,
        mechanism = :secondary,
        remove_disconnected = false,
    )
    @test species(secondary[end]) == [:wolf, :fox]

    cascade = extinction(
        network,
        [:plant];
        protect = :none,
        mechanism = :cascade,
        remove_disconnected = false,
    )
    @test isempty(species(cascade[end]))

    @test_throws ErrorException extinction(network, [:plant]; protect = :invalid)
    @test_throws ErrorException extinction(network, [:plant]; mechanism = :invalid)
end

@testset "disconnected species handling" begin
    spp = [:a, :b, :isolated]
    nodes = Unipartite(spp)
    edges = Binary(Bool[
        0 1 0
        0 0 0
        0 0 0
    ])
    network = SpeciesInteractionNetwork(nodes, edges)

    retained = extinction(
        network,
        [:a];
        protect = :none,
        remove_disconnected = false,
    )
    simplified = extinction(
        network,
        [:a];
        protect = :none,
        remove_disconnected = true,
    )

    @test Set(species(retained[end])) == Set([:b, :isolated])
    @test isempty(species(simplified[end]))
end

@testset "resilience area" begin
    spp = [:a, :b, :c, :d]
    nodes = Unipartite(spp)
    edges = Binary(zeros(Bool, 4, 4))
    network = SpeciesInteractionNetwork(nodes, edges)
    sequence = extinction(
        network,
        [:a, :b];
        protect = :none,
        remove_disconnected = false,
    )

    @test [richness(n) for n in sequence] == [4, 3, 2]
    @test resilience(sequence) ≈ 0.375
end
