module Google

using StructTypes
using Guard

import HTTP, JSON3, JSON, URIs

const AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
const TOKEN_URL = "https://oauth2.googleapis.com/token"
const USER_URL = "https://www.googleapis.com/oauth2/v3/userinfo"

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

function redirect_url(config::Guard.Configuration.Options)
    include_granted_scopes = "true"
    access_type = "offline"
    response_type = "code"

    query = """client_id=$(config.client_id)&redirect_uri=$(config.redirect_uri)&scope=$(config.scope)&include_granted_scopes=$(include_granted_scopes)&response_type=$(response_type)&access_type=$(access_type)"""

    return """$(AUTH_URL)?$(query)"""
end

function token_exchange(code::String, config::Guard.Configuration.Options; verbose::Int64=0)
    try
        tokens = _exchange_token(TOKEN_URL, code, config)
        profile = _get_user(USER_URL, tokens.access_token)
        return tokens, profile
    catch e
        return nothing, nothing
    end
end

function _get_user(url::String, access_token::String)
    headers = ["Authorization" => """Bearer $(access_token)"""]
    response = HTTP.get(url, headers)
    body = String(response.body)
    return JSON3.read(body, User)
end

function _exchange_token(url::String, code::String, config::Guard.Configuration.Options)
    headers = ["Content-Type" => "application/x-www-form-urlencoded"]
    grand_type = "authorization_code"

    body = """code=$(code)&client_id=$(config.client_id)&client_secret=$(config.client_secret)&redirect_uri=$(replace(config.redirect_uri, ":" => "%3A"))&grant_type=$(grand_type)"""

    response = HTTP.post(url, headers, body, verbose=2)
    body = String(response.body)
    tokens = JSON3.read(body, Tokens)

    return tokens
end

end