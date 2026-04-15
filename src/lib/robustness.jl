"""
    Calculates the robustness for a network. That is the proportion of primary extinction that result in
    the user specified % of species going extinct. This threshold is specified by `threshold`. Extinctions
    are randomised (unless a predetermined extinction sequence is specified.)
"""
function robustness(
    N::SpeciesInteractionNetwork{<:Partiteness,<:Binary};
    extinction_order::Union{Nothing,Vector{Symbol}} = nothing, 
    threshold::Int = 50,
    mechanism::Symbol = :cascade,
    remove_disconnected::Bool = false)

    # tests
    if mechanism ∉ [:cascade, :secondary]
        error("Invalid value for mechanism -- must be :cascade or :secondary")
    end

    initial_rich = richness(N)

    # for recording the number of primary extinctions
    num_prim = 0

    K = deepcopy(N)

    if extinction_order === nothing
        extinction_order = StatsBase.shuffle(species(K))
    end

    current_species = Set(species(K))

    # keep removing species until richness drops below threshold
    for (i, sp_primary) in enumerate(extinction_order)
        # check if sp in network
        if sp_primary ∈ current_species

            ext_seq = extinction(K, [sp_primary]; protect = :none, mechanism = mechanism, remove_disconnected = remove_disconnected)

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

"""
    robustness(network_sequence::Vector{<:SpeciesInteractionNetwork};
               threshold::Int = 50)

Calculate robustness from a precomputed extinction sequence of networks.
The sequence should go from the initial network to the fully extinct network.
"""
function robustness(
    network_sequence::Vector{<:SpeciesInteractionNetwork};
    threshold::Int = 50
)

    isempty(network_sequence) && error("network_sequence cannot be empty")

    S0 = richness(network_sequence[1])
    target = threshold / 100 * S0

    for net in network_sequence
        if richness(net) <= target
            return (S0 - richness(net)) / S0
        end
    end

    return (S0 - richness(network_sequence[end])) / S0
end