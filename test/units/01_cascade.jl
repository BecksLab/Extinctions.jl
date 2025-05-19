module SPTestCascade

using Extinctions
using SpeciesInteractionNetworks
using Test

# test cascade along a 'food chain'
spp = [:wolf, :fox, :rat, :plant]
nodes = Unipartite(spp)

int_matrix = Bool[
    0 1 0 0
    0 0 1 0
    0 0 0 1
    0 0 0 0
]
edges = Binary(int_matrix)

network = SpeciesInteractionNetwork(nodes, edges)
N = network

# removing the plant should kill all species
ext_seq = extinction(N, [:plant]; protect = :none)

# all species removed
@test richness(ext_seq[end]) == 0
# only one 'generation' of extinction
@test length(ext_seq) == 2

# Build a more 'complex' network
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

# add more links
spp = [:wolf, :fox, :hawk, :vole, :rat, :plant]
nodes = Unipartite(spp)

int_matrix = Bool[
    0 1 1 0 0 0
    0 0 0 1 1 0
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
@test species(ext_seq[end]) == [:wolf, :fox, :hawk, :vole]

# have a longer extinction sequence
ext_seq = extinction(N, [:vole, :rat]; protect = :none)

# test length of extinction 'generations'
@test length(ext_seq) == 3
# test composition of intermediate community (after vole removal)
@test species(ext_seq[2]) == [:wolf, :fox, :rat, :plant]
# test composition of final community (after vole and plant removal)
@test richness(ext_seq[end]) == 0

end
