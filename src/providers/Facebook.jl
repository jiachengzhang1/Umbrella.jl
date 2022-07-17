module Facebook

using StructTypes
using Umbrella

import HTTP, JSON3, URIs

const AUTH_URL = "https://www.facebook.com/v14.0/dialog/oauth"
const TOKEN_URL = "https://graph.facebook.com/v14.0/oauth/access_token"
const USER_URL = "https://graph.facebook.com/me"

Base.@kwdef mutable struct Tokens
    access_token::String=""
    refresh_token::String=""
    token_type::String=""
    expires_in::Int64=0
end

StructTypes.StructType(::Type{Tokens}) = StructTypes.Mutable()

Base.@kwdef mutable struct User
    id::String=""
    first_name::String=""
    last_name::String=""
    gender::String=""
    email::String=""
    picture_url::String=""
end

StructTypes.StructType(::Type{User}) = StructTypes.Mutable()

function redirect_url(config::Umbrella.Configuration.Options)
    state = "" # TODO: include state
    query = "client_id=$(config.client_id)&redirect_uri=$(config.redirect_uri)&state=$(state)"

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
    query = Dict(
        "access_token" => access_token,
        "fields" => join(["id", "first_name", "last_name", "picture", "gender", "email"], ",")
    )

    response = HTTP.get(url, query=query)

    body = String(response.body)
    user_dict = JSON3.read(body)

    user = User()

    haskey(user_dict, :id) && (user.id = user_dict[:id])

    haskey(user_dict, :first_name) && (user.first_name = user_dict[:first_name])
    
    haskey(user_dict, :last_name) && (user.last_name = user_dict[:last_name])

    haskey(user_dict, :gender) && (user.gender = user_dict[:gender])

    haskey(user_dict, :email) && (user.email = user_dict[:email])

    haskey(user_dict, :picture) && haskey(user_dict[:picture], :data) && 
    haskey(user_dict[:picture][:data], :url) && (user.picture_url = user_dict[:picture][:data][:url])
    
    return user
end

function _exchange_token(url::String, code::String, config::Umbrella.Configuration.Options)
    query = Dict(
        "client_id" => config.client_id,
        "redirect_uri" => config.redirect_uri,
        "client_secret" => config.client_secret,
        "code" => code
    )

    response = HTTP.get(url, query=query)

    body = String(response.body)
    tokens = JSON3.read(body, Tokens)
    return tokens
end

Umbrella.register(:facebook, Umbrella.OAuth2Actions(redirect_url, token_exchange))

end
