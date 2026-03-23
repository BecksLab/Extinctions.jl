"""
    Returns the area under a robustness curve (using the trapezoidal rule formula)
"""
function _auc(x::Vector{T}, y::Vector{T}) where {T<:Number}
    @assert length(x) == length(y)
    @assert issorted(x)

    area = 0.0
    for i = 2:length(x)
        area += 0.5 * (x[i] - x[i-1]) * (y[i] + y[i-1])
    end
    return area
end

"""
    Returns the AUC (area under curve) for an extinction curve, i.e., the primary vs secondary extinctions.
"""
function resilience(
    Ns::Vector{T};
    dims::Union{Nothing,Int64} = nothing,
) where {T<:SpeciesInteractionNetwork}
    
    initial = richness(first(Ns))
    primary = (initial .- richness.(Ns)) ./ initial

    if isnothing(dims)
        remaining = richness.(Ns) ./ richness(first(Ns))
    else

        remaining = richness.(Ns; dims = dims) ./ richness(first(Ns); dims = dims)
    end
    return _auc(primary, remaining)
end
