module SPTestAllGood
using Extinctions
using DataFrames
using Test

@testset "numeric trait ordering" begin
    traits = Dict(:a => 1, :b => 3, :c => 2)

    @test extinctionsequence(traits) == [:a, :c, :b]
    @test extinctionsequence(traits; descending = true) == [:b, :c, :a]
end

@testset "categorical trait hierarchy" begin
    traits = DataFrame(
        species = [:a, :b, :c],
        trait = ["low", "high", "low"],
    )
    hierarchy = ["low", "high"]

    order = extinctionsequence(hierarchy, traits)
    @test Set(order[1:2]) == Set([:a, :c])
    @test order[3] == :b

    descending_order = extinctionsequence(hierarchy, traits; descending = true)
    @test descending_order[1] == :b
    @test Set(descending_order[2:3]) == Set([:a, :c])

    @test_throws ErrorException extinctionsequence(["low"], traits)
end

end
