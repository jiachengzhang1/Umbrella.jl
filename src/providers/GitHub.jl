module GitHub

using StructTypes
using Guard

import HTTP, JSON3, JSON, URIs

const AUTH_URL = "https://github.com/login/oauth/authorize"
const TOKEN_URL = "https://github.com/login/oauth/access_token"
const USER_URL = "https://api.github.com/user"

mutable struct Tokens
    access_token::String
    scope::String
    token_type::String

    function Tokens(; access_token::String="", scope::String="", token_type::String="")
        return new(access_token, scope, token_type)
    end
end

StructTypes.StructType(::Type{Tokens}) = StructTypes.Mutable()

mutable struct User end


function redirect_url(config::Guard.Configuration.Options)
    login = ""
    state = "asdfasgsfqerwrtgedf"
    allow_signup = "true"

    query = """client_id=$(config.client_id)&redirect_uri=$(config.redirect_uri)&scope=$(config.scope)&login=$(login)&state=$(state)&allow_signup=$(allow_signup)"""

    return """$(AUTH_URL)?$(query)"""
end

function token_exchange(code::String, config::Guard.Configuration.Options)
    headers = ["Content-Type" => "application/json"]

    body = Dict(
        "code" => code,
        "client_id" => config.client_id,
        "client_secret" => config.client_secret,
        "redirect_uri" => config.redirect_uri,
    )

    tokens = _token_exchange(TOKEN_URL, headers, JSON.json(body))
    profile = _get_user(USER_URL, tokens.access_token)

    return tokens, profile
end

function _get_user(url::String, access_token::String)
    headers = ["Authorization" => """Bearer $(access_token)"""]
    response = HTTP.get(url, headers)
    body = String(response.body)
    return JSON3.read(body, User)
end

function _token_exchange(url::String, headers::Vector{Pair{String,String}}, body::String)
    response = HTTP.post(url, headers, body, verbose=2)

    tokens = JSON3.read(JSON.json(URIs.queryparams(String(response.body))), Tokens)

    return tokens
end

end