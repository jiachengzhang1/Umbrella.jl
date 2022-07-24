module Google

using StructTypes
using Umbrella

import HTTP, JSON3, URIs

const AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
const TOKEN_URL = "https://oauth2.googleapis.com/token"
const USER_URL = "https://www.googleapis.com/oauth2/v3/userinfo"

export GoogleOptions

Base.@kwdef struct GoogleOptions <: Umbrella.Configuration.ProviderOptions
    response_type::String = "code"
    access_type::String = "offline" # online or offline
    include_granted_scopes::Union{Bool,Nothing} = nothing
    login_hint::Union{String,Nothing} = nothing
    prompt::Union{String,Nothing} = nothing # none, consent, select_account
end

mutable struct Tokens
    access_token::String
    refresh_token::String
    scope::String
    expires_in::Int64

    function Tokens(; access_token::String="", refresh_token::String="", scope::String="", expires_in::Int64=0)
        return new(access_token, refresh_token, scope, expires_in)
    end
end

StructTypes.StructType(::Type{Tokens}) = StructTypes.Mutable()

mutable struct User
    sub::String
    given_name::String
    family_name::String
    picture::String
    email::String
    email_verified::Bool
    locale::String

    function User(;
        sub::String="",
        given_name::String="",
        family_name::String="",
        picture::String="",
        email::String="",
        email_verified::Bool=false,
        locale::String=""
    )
        return new(sub, given_name, family_name, picture, email, email_verified, locale)
    end
end

StructTypes.StructType(::Type{User}) = StructTypes.Mutable()

function redirect_url(config::Umbrella.Configuration.Options)
    if config.providerOptions === nothing
        googleOptions = GoogleOptions()
    else
        googleOptions = config.providerOptions
    end
    
    state = config.state
    include_granted_scopes = googleOptions.include_granted_scopes
    access_type = googleOptions.access_type
    response_type = googleOptions.response_type
    prompt = googleOptions.prompt
    login_hint = googleOptions.login_hint

    params = [
        "client_id=$(config.client_id)",
        "redirect_uri=$(config.redirect_uri)",
        "scope=$(config.scope)",
        "access_type=$(access_type)",
        "response_type=$(response_type)",
    ]

    if state !== nothing
        push!(params, "state=$(state)")
    end

    if include_granted_scopes !== nothing
        push!(params, "include_granted_scopes=$(String(include_granted_scopes))")
    end

    if prompt !== nothing
        push!(params, "prompt=$(prompt)")
    end

    if login_hint !== nothing
        push!(params, "login_hint=$(login_hint)")
    end

    query = join(params, "&")
    println(query)
    return "$(AUTH_URL)?$(query)"
end

function token_exchange(code::String, config::Umbrella.Configuration.Options)
    try
        tokens = _exchange_token(TOKEN_URL, code, config)
        profile = _get_user(USER_URL, tokens.access_token)
        return tokens, profile
    catch e
        @error "Unable to complete token exchange" exception=(e, catch_backtrace())
        return nothing, nothing
    end
end

function _get_user(url::String, access_token::String)
    headers = ["Authorization" => """Bearer $(access_token)"""]
    response = HTTP.get(url, headers)
    body = String(response.body)
    return JSON3.read(body, User)
end

function _exchange_token(url::String, code::String, config::Umbrella.Configuration.Options)
    headers = ["Content-Type" => "application/x-www-form-urlencoded"]
    grand_type = "authorization_code"

    body = """code=$(code)&client_id=$(config.client_id)&client_secret=$(config.client_secret)&redirect_uri=$(replace(config.redirect_uri, ":" => "%3A"))&grant_type=$(grand_type)"""

    response = HTTP.post(url, headers, body)
    body = String(response.body)
    tokens = JSON3.read(body, Tokens)

    return tokens
end

Umbrella.register(:google, Umbrella.OAuth2Actions(redirect_url, token_exchange))

end