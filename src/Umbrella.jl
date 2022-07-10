module Umbrella

include("Configuration.jl")
include("initiator.jl")
include("providers/Google.jl")
include("providers/GitHub.jl")

export Configuration, OAuth2Actions
export init, register

end # module
