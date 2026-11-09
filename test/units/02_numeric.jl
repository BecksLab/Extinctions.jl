module SPTestNumeric

using Extinctions
using JLD2
using SpeciesInteractionNetworks
using Test

# Build network
spp = [:wolf, :fox, :hawk, :vole, :rat, :plant]
nodes = Unipartite(spp)

int_matrix = Bool[
    0 1 1 0 0 0
    0 0 0 0 1 0
    0 0 0 1 0 0
    0 0 0 0 0 0
    0 0 0 0 0 1
    0 0 0 0 0 0
]
edges = Binary(int_matrix)

network = SpeciesInteractionNetwork(nodes, edges)
N = network

ext_seq = extinction(N, "generality", true; protect = :none)

# Test the dynamic extinction path and its selected first removal.
@test species(ext_seq[1]) == species(N)
@test :wolf ∉ species(ext_seq[2])
@test Set(species(ext_seq[3])) == Set([:hawk, :vole, :rat, :plant])
@test richness(ext_seq[end]) == 0

### more complex

# import networks
networks = load_object("data/networks.jlds")

N = networks.network[3]

ext_seq = extinction(N, "generality", true; protect = :basal)
@test species(ext_seq[1]) == species(N)
@test length(ext_seq) > 1

end