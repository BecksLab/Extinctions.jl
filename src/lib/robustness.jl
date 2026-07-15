"""
    Calculates the robustness for a network using linear interpolation to handle 
    discrete-step overshooting of the specified threshold.
"""
function robustness(
    N::SpeciesInteractionNetwork{<:Partiteness,<:Binary};
    extinction_order::Union{Nothing,Vector{Symbol}} = nothing, 
    threshold::Int = 50,
    mechanism::Symbol = :cascade,
    remove_disconnected::Bool = false)

    if mechanism ∉ [:cascade, :secondary]
        error("Invalid value for mechanism -- must be :cascade or :secondary")
    end

    initial_rich = richness(N)
    target = threshold / 100.0

    if extinction_order === nothing
        extinction_order = StatsBase.shuffle(species(N))
    end

    K = deepcopy(N)
    current_species = Set(species(K))

    # Track the previous point (start at 0 extinctions, 100% richness)
    prev_x = 0.0
    prev_y = 1.0
    num_prim = 0

    for sp_primary in extinction_order
        if sp_primary ∈ current_species
            ext_seq = extinction(K, [sp_primary]; protect = :none, mechanism = mechanism, remove_disconnected = remove_disconnected)
            K = ext_seq[end]
            
            # Note: updating current_species ensures we don't try to delete 
            # species that have already gone secondary-extinct.
            current_species = Set(species(K)) 

            # Calculate metrics for the current step
            curr_x = (num_prim + 1) / initial_rich
            curr_y = richness(K) / initial_rich

            # If we crossed the threshold, interpolate and return immediately
            if curr_y < target
                return prev_x + (target - prev_y) * (curr_x - prev_x) / (curr_y - prev_y)
            end

            # Otherwise, update tracking variables and continue
            num_prim += 1
            prev_x = curr_x
            prev_y = curr_y
        end
    end

    return prev_x
end

"""
    robustness(network_sequence::Vector{<:SpeciesInteractionNetwork};
               threshold::Int = 50)

Calculate robustness from a precomputed extinction sequence of networks
using linear interpolation.
"""
function robustness(
    network_sequence::Vector{<:SpeciesInteractionNetwork};
    threshold::Int = 50
)
    isempty(network_sequence) && error("network_sequence cannot be empty")

    initial_rich = richness(network_sequence[1])
    target = threshold / 100.0

    # Track previous point
    prev_x = 0.0
    prev_y = 1.0

    for i in 2:length(network_sequence)
        curr_x = (i - 1) / initial_rich
        curr_y = richness(network_sequence[i]) / initial_rich

        if curr_y < target
            return prev_x + (target - prev_y) * (curr_x - prev_x) / (curr_y - prev_y)
        end

        prev_x = curr_x
        prev_y = curr_y
    end

    return prev_x
end