using Documenter, Umbrella

makedocs(
  sitename = "Umbrella.jl",
  format = Documenter.HTML(),
  modules = [Umbrella],
  pages = [
    "Overview" => "index.md",
    "API Reference" => "reference.md",
    "Examples" => "examples.md",
  ]
)