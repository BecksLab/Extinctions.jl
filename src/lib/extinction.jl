"""
extinction(N::SpeciesInteractionNetwork, end_richness::Int64)

    Function to simulate random, cascading extinctions of an initial network `N` until 
    the richness is less than or equal to that specified by `end_richness`. Protect
    specifies which species should not be selected for extinction, by default all
    basal species are protected
"""
function extinction(
    N::SpeciesInteractionNetwork{<:Partiteness,<:Binary};
    end_richness::Int64 = 0,
    protect::Symbol = :basal,
)
    if richness(N) <= end_richness
        throw(ArgumentError("Richness of starting community is less than final community"))
    end
    if protect ∉ [:none, :basal, :consumer]
        error("Invalid value for protect -- must be :none, :basal or :consumer")
    end

    # get list for all species
    extinction_list = StatsBase.shuffle(SpeciesInteractionNetworks.species(N))

    # apply protection rules
    extinction_list = _protect(N, protect, extinction_list)
    # create object to store networks at each timestamp
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
    extinction_list::Vector{Symbol};
    end_richness::Int64 = 0,
    protect::Symbol = :none,
)
    if richness(N) <= end_richness
        throw(ArgumentError("Richness of final community is less than starting community"))
    end
    if protect ∉ [:none, :basal, :consumer]
        error("Invalid value for protect -- must be :none, :basal or :consumer")
    end
   # if !issubset(species(N), extinction_list)
   #     throw(
   #         ArgumentError(
   #             "Species in the network do not match those specified in `extinction_list`",
   #         ),
   #     )
   # end

   # apply protection rules
   extinction_list = _protect(N, protect, extinction_list)

    network_series = Vector{SpeciesInteractionNetwork{<:Partiteness,<:Binary}}()
    # push initial network
    push!(network_series, deepcopy(N))

    return _speciesremoval(network_series, extinction_list, end_richness)
end