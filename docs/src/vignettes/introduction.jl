# # Introduction

# The goal of this project is simple: impliment different extinction mechanisms
# for species interaction networks of the type `SpeciesInteractionNetworks`.
# For now all extinction are secondary - *i.e.,* after the extinction of one
# species we will also remove species that no longer have any prey (are unconnected).
# However there is functionality for the order that the species are removed - 
# *i.e.,* simulating different extinction mechanisms.

# > note that this project is not officially hosted as a Julia package and so
# > must be installed from github using 
# > `Pkg.add https://github.com/TanyaS08/Extinctions.jl`. The same holds true
# > for the `SpeciesInteractionNetworks`

# **Random:** Species order is randomly determined.

# **Hierarchical:** Order is determined by the categorical traits of species *e.g.,*
# feeding mechanism.

# **Numeric:** Order is determined by the numeric 'traits' of species *e.g.,* size.

# In this example, we will see how the `Extinction.jl` package works by creating a
# network using a iche model from the `SpeciesInteractionNetworks` package and
# simulate a random extinction. 

using Extinctions
using SpeciesInteractionNetworks

# First lets create a network:

