module Umbrella

include("Configuration.jl")
include("initiator.jl")

const PROVIDER_DIR = joinpath(@__DIR__, "providers")

for file in readdir(PROVIDER_DIR)
  name, ext = splitext(file)
  if ext == ".jl"
    include(joinpath(PROVIDER_DIR, "$(name).jl"))
    eval(Expr(:export, Symbol(name)))
  end
end

export Configuration, OAuth2Actions
export init, register

end # module
