using Documenter
using Extinctions

makedocs(
    sitename = "Extinctions",
    pages = [
        "Introduction" => "vignettes/introduction.md",
        "Extinctions" => "vignettes/extinctions.md",
    ],
)

deploydocs(
    repo = "github.com/BecksLab/Extinctions.jl.git",
    devbranch = "main",
)
