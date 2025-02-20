module Extinctions

# Dependencies
using DataFrames
using DataFramesMeta
using SpeciesInteractionNetworks
using StatsBase

include(joinpath("lib", "extinctionsequence.jl"))
export extinctionsequence

include(joinpath("lib", "speciesremoval.jl"))
include(joinpath("lib", "protection.jl"))

include(joinpath("lib", "extinction.jl"))

export extinction

include(joinpath("lib", "robustness.jl"))

export robustness

end # module Extinctions
