"""
_protect(N::SpeciesInteractionNetwork{<:Partiteness,<:Binary}, protect::Symbol, extinction_list::Vector{String})

    Internal for extinction function. Determines which species (if any) should
    be removed from the extinction sequence list - i.e. not targeted for
    extinction.
"""
function _protect(
    N::SpeciesInteractionNetwork{<:Partiteness,<:Binary},
    protect::Symbol,
    extinction_list::Vector{Symbol},
)
    # get generality of all spp
    gen = SpeciesInteractionNetworks.generality(N)

    # we must protect basal species - remove them from extinction list
    if protect == :basal
        # identify basal species
        filter!(v -> last(v) == 0, gen)
        # remove the species previously identified as basal
        filter!(x -> x ∉ collect(keys(gen)), extinction_list)
    elseif protect == :consumer
        # identify basal species
        filter!(v -> last(v) > 0, gen)
        # remove the species previously identified as basal
        filter!(x -> x ∉ collect(keys(gen)), extinction_list)
    end

    return extinction_list
end
