"""
    Calculates the robustness for a series of networks. That is the proportion of primary extinction that result in
    the user specified % of species going extinct. This threshold is specified by `threshold`
"""
function robustness(Ns::Vector{T}; threshold::Int = 50) where {T<:SpeciesInteractionNetwork}

    # get initial richness
    init_rich = richness(Ns[1])

    # threshold richness
    thresh_rich = floor(Int, threshold / 100 * init_rich)

    # get first index in network series that is equal to or less than e50
    net_in = findfirst(x -> x <= thresh_rich, richness.(Ns))

    # return R50
    return net_in / init_rich
end
