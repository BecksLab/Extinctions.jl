module SPTestRobustnessResilience

using Extinctions
using SpeciesInteractionNetworks
using Test

# Simple chain network
spp = [:wolf, :fox, :rat, :plant]
nodes = Unipartite(spp)

int_matrix = Bool[
    0 1 0 0
    0 0 1 0
    0 0 0 1
    0 0 0 0
]

edges = Binary(int_matrix)
N = SpeciesInteractionNetwork(nodes, edges)

# TEST: robustness (deterministic)
# Removing plant collapses entire network immediately

r = robustness(
    N;
    extinction_order = [:plant]
)

# Only 1 removal needed out of 4 species
@test r == 0

# --------------------------------
# TEST: robustness threshold edge
# --------------------------------
# threshold = 100 → no collapse ever triggered until full removal

r_full = robustness(
    N;
    extinction_order = [:plant, :rat, :fox, :wolf],
    threshold = 100
)

@test r_full == 0.0

# --------------------------------
# TEST: robustness full collapse threshold
# --------------------------------
# threshold = 0 → collapse immediately

r_zero = robustness(
    N;
    extinction_order = [:plant, :rat, :fox, :wolf],
    threshold = 1
)

@test r_zero == 0.0

# --------------------------------
# TEST: resilience (AUC extremes)
# --------------------------------

# Case 1: no extinction (flat line at 1)
Ns_flat = [N, N, N]
@test resilience(Ns_flat) == 0.0

# --------------------------------
# TEST: resilience known curve
# --------------------------------
# richness trajectory: 4 → 3 → 2 → 1 → 0
Ns_seq = extinction(N, [:plant]; protect = :none)

auc_val = resilience(Ns_seq)

# Expected: linear decline → AUC ≈ 0.5
@test auc_val ≈ 0.5

# --------------------------------
# TEST: resilience monotonicity
# --------------------------------
secondary = richness.(Ns_seq) ./ richness(first(Ns_seq))

@test all(diff(secondary) .<= 0)

end