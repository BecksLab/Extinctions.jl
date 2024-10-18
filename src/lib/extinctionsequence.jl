"""
extinctionsequence(hierarchy::Vector{Any}, trait_data::DataFrame; descending::Bool = false)

    Determine the order of species extinction for categorical traits. Using a specified hierarchy
"""
function extinctionsequence(hierarchy::Vector{String}, trait_data::DataFrame; descending::Bool = false)
    # data checks
    if !issubset(String.(trait_data.trait), hierarchy)
        error("Not all traits in `traits_data` are listed in `hierarchy`")
    end

    # reverse order of trait hierarchy if descending is true
    if descending == true
        hierarchy = reverse(hierarchy)
    end

    df = @rorderby trait_data findfirst(==(:trait), hierarchy)
    return Symbol.(df.species)
end

"""
extinctionsequence(hierarchy::Vector{Any}, trait_data::DataFrame; descending::Bool = false)

    Determine the order of species extinction for numeric traits.
"""
function extinctionsequence(trait_dict::Dict{Symbol,Int64}; descending::Bool = false)
    return collect(keys(sort(trait_dict; byvalue = true, rev = descending)))
end