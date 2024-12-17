"""
_speciesremoval(N::SpeciesInteractionNetwork, end_richness::Int64)

    Internal function that does the species removal simulations within extinction()
"""
function _speciesremoval(
    network_series::Vector{SpeciesInteractionNetwork{<:Partiteness,<:Binary}},
    extinction_list::Vector{Symbol},
    end_richness::Int64,
)

    for (i, sp_to_remove) in enumerate(extinction_list)
        N = network_series[i]
        species_to_keep =
            filter(sp -> sp != sp_to_remove, SpeciesInteractionNetworks.species(N))
        K = subgraph(N, species_to_keep)
        K = simplify(K)
        # end if target richness reached
        if richness(K) == end_richness
            push!(network_series, K)
            break
        # if richness below target then we break without pushing
        elseif richness(K) < end_richness
            break
        # continue removing species
        else
            push!(network_series, K)
            continue
        end
    end
    return network_series
end