using Documenter
using Literate

# manual import of `SpeciesInteractionsNetworks`
using Pkg
Pkg.add(url="https://github.com/PoisotLab/SpeciesInteractionNetworks.jl")
Pkg.add(url="https://github.com/TanyaS08/Extinctions.jl")

@info "Prepare to compile"
vignettes_dir = joinpath("src", "vignettes")
for vignette in readdir(vignettes_dir)
    if occursin(".jl", vignette)
        Literate.markdown(joinpath(vignettes_dir, vignette), vignettes_dir; credit = false)
    end
end

@info "Prepare to build"
makedocs(;
    sitename = "Extinctions",
    format = Documenter.HTML(),
    modules = [Extinctions],
    pages = [
        "Home" => [
            "Introduction" => "vignettes/introduction.md",
            "Extinctions.jl" => "index.md",
        ],
        "Vignettes" => [
            "Extinction sequence" => "vignettes/extinctions.md",
        ],
    ],
)

@info "Prepare to remove"
run(`find . -type f -name ".tif" -delete`)
run(`find . -type f -name ".tif"`)

@info "Prepare to deploy"
deploydocs(;
    deps = Deps.pip("pygments", "python-markdown-math"),
    repo = "github.com/TanyaS08/Extnctions.jl.git",
    push_preview = true,
    devbranch = "main",
)