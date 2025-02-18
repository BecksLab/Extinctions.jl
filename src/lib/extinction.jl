"""
extinction(N::SpeciesInteractionNetwork, end_richness::Int64)

    Function to simulate random, cascading extinctions of an initial network `N` until 
    the richness is less than or equal to that specified by `end_richness`.
"""
function extinction(
    N::SpeciesInteractionNetwork{<:Partiteness,<:Binary},
    end_richness::Int64,
)
    if richness(N) <= end_richness
        throw(ArgumentError("Richness of starting community is less than final community"))
    end

    extinction_list = StatsBase.shuffle(SpeciesInteractionNetworks.species(N))
    network_series = Vector{SpeciesInteractionNetwork{<:Partiteness,<:Binary}}()
    # push initial network
    push!(network_series, deepcopy(N))

    return _speciesremoval(network_series, extinction_list, end_richness)
end

"""
extinction(N::SpeciesInteractionNetwork, extinction_list::Vector{String}, end_richness::Int64)

    Function to simulate cascading extinctions of an initial network `N` until the richness
    is less than or equal to that specified by `end_richness`. The order of species removal
    (extinction) is specified by `extinction_list`
"""
function extinction(
    N::SpeciesInteractionNetwork{<:Partiteness,<:Binary},
    extinction_list::Vector{Symbol},
    end_richness::Int64,
)
    if richness(N) <= end_richness
        throw(ArgumentError("Richness of final community is less than starting community"))
    end
   # if !issubset(species(N), extinction_list)
   #     throw(
   #         ArgumentError(
   #             "Species in the network do not match those specified in `extinction_list`",
   #         ),
   #     )
   # end

    network_series = Vector{SpeciesInteractionNetwork{<:Partiteness,<:Binary}}()
    # push initial network
    push!(network_series, deepcopy(N))

    return _speciesremoval(network_series, extinction_list, end_richness)
end