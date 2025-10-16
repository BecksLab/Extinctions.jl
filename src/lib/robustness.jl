"""
    Calculates the robustness for a network. That is the proportion of primary extinction that result in
    the user specified % of species going extinct. This threshold is specified by `threshold`. Extinctions
    are randomised (unless a predetermined extinction sequence is specified.)
"""
function robustness(
    N::SpeciesInteractionNetwork{<:Partiteness,<:Binary};
    extinction_order::Union{Nothing,Vector{Symbol}} = nothing, 
    threshold::Int = 50,
    mechanism::Symbol = :cascade)

    # tests
    if mechanism ∉ [:cascade, :secondary]
        error("Invalid value for mechanism -- must be :cascade or :secondary")
    end

    initial_rich = richness(N)
    percent_loss = initial_rich*(threshold/100)

    # for recording the number of primary extinctions
    num_prim = 1

    K = N

    if extinction_order === nothing
        extinction_order = StatsBase.shuffle(species(K))
    end

    # keep removing species until richness drops below threshold
    for (i, sp_primary) in enumerate(extinction_order)
        # check if sp in network
        if sp_primary ∈ SpeciesInteractionNetworks.species(K)

            ext_seq = extinction(K, [sp_primary]; protect = :none, mechanism = mechanism, remove_disconnected = false)

            K = ext_seq[end]

            if richness(K) / initial_rich >= (threshold/100)
                # keep record of the number of primary extinctions
                num_prim += 1
                continue
            else
                break
            end
        end
    end

    # return prop of primary extinctions as total number of initial species
    return num_prim/initial_rich

end
