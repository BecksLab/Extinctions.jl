using SpeciesInteractionNetworks

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