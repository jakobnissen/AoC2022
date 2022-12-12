using Documenter, AoC2022

DocMeta.setdocmeta!(AoC2022, :DocTestSetup, :(using AoC2022); recursive=true)

makedocs(
    format = Documenter.HTML(),
    sitename = "AoC2022",
    pages = [
        "Home" => "index.md"
        "Notes" => "notes.md"
    ],
    authors = "Jakob Nybo Nissen"
)

deploydocs(repo = "github.com/jakobnissen/AoC2022.git")
