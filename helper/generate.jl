import ArgParse: ArgParseSettings, parse_args, @add_arg_table!
import Mustache

include("templates.jl")

function parse_commandline()
  s = ArgParseSettings(description = "Generate code stub for an OAuth2 provider.")

  @add_arg_table! s begin
    "--provider", "-p"         # another option, with short form
      help = "the name of the new provider"
      arg_type = String
    "action"                 # a positional argument
      help = "'init' to initialize the configuration file, 'run' to generate the new provider"
      required = true
  end

  return parse_args(s)
end

parsed_args = parse_commandline()

action = parsed_args["action"]

const ROOT = dirname(@__DIR__)
const HELPER_DIR = @__DIR__
const PROVIDER_DIR = joinpath(ROOT, "src", "providers")

const CONFIG_FILE = "config_generated.jl"
const CONFIG_FILE_DIR = joinpath(HELPER_DIR, CONFIG_FILE)

if action == "init"

  provider = uppercasefirst(parsed_args["provider"])

  config_f = Mustache.render(
    config_tpl, 
    Dict("provider" => provider, "provider_symbol" => lowercase(provider))
  )
  
  open(CONFIG_FILE_DIR, "w") do f
    write(f, config_f)
  end

elseif action == "run"

  if !isfile(CONFIG_FILE_DIR)
    @error "$(CONFIG_FILE) is not found, run command with 'init' first"
    exit(1)
  end

  include(CONFIG_FILE_DIR)

  file = "$(config["provider"]).jl"
  path = joinpath(PROVIDER_DIR, file)
  
  if isfile(path)
    @warn "$file exists, provider is not generated"
    exit(1)
  end

  open(path, "w") do f
    write(f, Mustache.render(provider_tpl, config))
  end

  rm(CONFIG_FILE_DIR, force=true)
else
  "$(action) is not an option, use 'init' or 'run', see more using --help" |> println
end
