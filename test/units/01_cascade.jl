module SPTestCascade

using Extinctions
using SpeciesInteractionNetworks
using Test

# Build a network
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

ext_seq = extinction(N, [:plant]; protect = :none)

# test if interaction pairs match up
@test species(ext_seq[end]) == [:wolf, :hawk, :vole]

end
