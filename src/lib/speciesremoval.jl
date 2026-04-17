"""
_speciesremoval(N::SpeciesInteractionNetwork, end_richness::Int64)

    Internal function that does the species removal simulations within extinction(). Note
    that this is preforming a cascade extinction - after a primary extinction secondary extinctions
    will continue beyond a secondary extinction.
"""
function _speciesremoval(
    network_series::Vector{SpeciesInteractionNetwork{<:Partiteness,<:Binary}},
    extinction_list::Vector{Symbol},
    end_richness::Int64;
    mechanism::Symbol = :cascade,
    remove_disconnected::Bool = true
)

    # --- identify ORIGINAL basal species (never go extinct) ---
    gen0 = SpeciesInteractionNetworks.generality(network_series[1])
    basal_spp = Set(k for (k,v) in gen0 if v == 0)

    for sp_to_remove in extinction_list

        N = network_series[end]

        # skip if already gone
        if !(sp_to_remove ∈ SpeciesInteractionNetworks.species(N))
            continue
        end

        # --- PRIMARY EXTINCTION ---
        spp_keep = filter(sp -> sp != sp_to_remove, SpeciesInteractionNetworks.species(N))
        K = subgraph(N, spp_keep)

        # --- CASCADE LOOP ---
        if mechanism == :cascade

            while true
                gen = SpeciesInteractionNetworks.generality(K)

                # consumers that lost all prey (exclude original basal spp)
                to_remove = [
                    sp for (sp, g) in gen
                    if g == 0 && !(sp in basal_spp)
                ]

                isempty(to_remove) && break

                spp_keep = filter(sp -> !(sp in to_remove), SpeciesInteractionNetworks.species(K))
                K = subgraph(K, spp_keep)
            end

        elseif mechanism == :secondary

            gen = SpeciesInteractionNetworks.generality(K)

            to_remove = [
                sp for (sp, g) in gen
                if g == 0 && !(sp in basal_spp)
            ]

            if !isempty(to_remove)
                spp_keep = filter(sp -> !(sp in to_remove), SpeciesInteractionNetworks.species(K))
                K = subgraph(K, spp_keep)
            end
        end

        # --- OPTIONAL: remove truly isolated species (no links at all) ---
        if remove_disconnected
            A = adjacency(K)

            has_prey = vec(sum(A, dims=2)) .> 0
            has_pred = vec(sum(A, dims=1)) .> 0

            spp = SpeciesInteractionNetworks.species(K)

            keep_mask = has_prey .| has_pred .| [sp in basal_spp for sp in spp]

            if any(.!keep_mask)
                spp_keep = spp[keep_mask]
                K = subgraph(K, spp_keep)
            end
        end

        # --- STOP CONDITIONS ---
        r = SpeciesInteractionNetworks.richness(K)

        if r == end_richness
            push!(network_series, K)
            break
        elseif r < end_richness
            break
        else
            push!(network_series, K)
        end
    end

    return network_series
end