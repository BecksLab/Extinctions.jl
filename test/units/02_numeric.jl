module SPTestNumeric

using Extinctions
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

# test if fox first species removed
@test :wolf ∉ species(ext_seq[2])
# test if rat (and by extension plant removed)
@test [:rat, :plant] ∉ species(ext_seq[3])
# test final community completely extinct
@test richness(ext_seq[end]) == 0

end