import Mustache

provider_tpl = Mustache.mt"""
module {{provider}}

using StructTypes
using Umbrella

import HTTP, JSON3, URIs

const AUTH_URL = "{{{provider_auth_url}}}"
const TOKEN_URL = "{{{provider_token_url}}}"
const USER_URL = "{{{provider_user_url}}}"

Base.@kwdef mutable struct Tokens
    {{#token_fields}}
    {{name}}::{{type}}={{#default}}{{default}}{{/default}}{{^default}}""{{/default}}
    {{/token_fields}}
end

StructTypes.StructType(::Type{Tokens}) = StructTypes.Mutable()

Base.@kwdef mutable struct User
    {{#user_fields}}
    {{name}}::{{type}}={{#default}}{{default}}{{/default}}{{^default}}""{{/default}}
    {{/user_fields}}
end

StructTypes.StructType(::Type{User}) = StructTypes.Mutable()

function redirect_url(config::Umbrella.Configuration.Options)
    # TODO: implement building {{provider}} redirect url
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
    # TODO: implement {{provider}} get user
end

function _exchange_token(url::String, code::String, config::Umbrella.Configuration.Options)
    # TODO: implement {{provider}} token exchange
end

Umbrella.register(:{{provider_symbol}}, Umbrella.OAuth2Actions(redirect_url, token_exchange))

end
"""

config_tpl = Mustache.mt"""
config = Dict(
    "provider" => "{{provider}}",
    "provider_symbol" => "{{provider_symbol}}",
    "provider_auth_url" => "",
    "provider_token_url" => "",
    "provider_user_url" => "",
    "token_fields" => [
        # TODO: model the token fields required by the oauth2 provider, example below
        Dict("name" => "access_token", "type" => "String", "default" => ""),
        Dict("name" => "refresh_token", "type" => "String", "default" => ""),
        Dict("name" => "expires_in", "type" => "Int64", "default" => 0),
    ],
    "user_fields" => [
        # TODO: model the user fields required by the oauth2 provider, example below
        Dict("name" => "first_name", "type" => "String", "default" => ""),
        Dict("name" => "last_name", "type" => "String", "default" => ""),
        Dict("name" => "email", "type" => "String", "default" => ""),
    ],
)
"""
