"""
_speciesremoval(N::SpeciesInteractionNetwork, end_richness::Int64)

    Internal function that does the species removal simulations within extinction(). Note
    that this is preforming a cascade extinction - after a primary extinction secondary extinctions
    will continue beyond a secondary extinction.
"""
function _speciesremoval(
    network_series::Vector{SpeciesInteractionNetwork{<:Partiteness,<:Binary}},
    extinction_list::Vector{Symbol},
    end_richness::Int64,
)
    # identify basal spp (generality = 0) - this is so that we don't remove them
    # when we do the secondary extinctions
    gen = SpeciesInteractionNetworks.generality(network_series[1])
    basal_spp = collect(keys(filter(((k, v),) -> v == 0, gen)))

    for (i, sp_to_remove) in enumerate(extinction_list)
        N = network_series[end]

        # check that spp is still in network
        if sp_to_remove ∈ SpeciesInteractionNetworks.species(N)

            species_to_keep =
                filter(sp -> sp != sp_to_remove, SpeciesInteractionNetworks.species(N))

            # primary extinction
            global K = subgraph(N, species_to_keep)

            # TODO this can possibly be made way more elegant...
            # identify all species with generality of zero (no prey)
            gen = generality(K)
            filter!(v -> last(v) == 0, gen)
            gen0 = collect(keys(gen))
            # remove the species previously identified as basal
            # this is because we don't want to remove basal species just those that are now gen0
            filter!(x -> x ∉ basal_spp, gen0)

            while length(gen0) > 0

            # identify all species with generality of zero (no prey)
            gen = generality(K)
            filter!(v -> last(v) == 0, gen)
            gen0 = collect(keys(gen))
            # remove the species previously identified as basal
            # this is because we don't want to remove basal species just those that are now gen0
            filter!(x -> x ∉ basal_spp, gen0)
                
            # update spp_to_keep list (don't include gen0 spp)
            spp_keep = filter(sp -> sp ∉ gen0, SpeciesInteractionNetworks.species(K))

            # nth extinction
            K = subgraph(K, spp_keep)

            # 'bycatch' - drop species now isolated
            global K = simplify(K)

            end

            # end if target richness reached
            if SpeciesInteractionNetworks.richness(K) == end_richness
                push!(network_series, K)
                break
                # if richness below target then we break without pushing
            elseif SpeciesInteractionNetworks.richness(K) < end_richness
                break
                # continue removing species
            else
                push!(network_series, K)
                continue
            end
        end
    end
    return network_series
end
