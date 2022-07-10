module GitHub

using StructTypes
using Umbrella

import HTTP, JSON3, URIs

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

mutable struct User
    login::String
    id::Int64
    node_id::String
    avatar_url::String
    gravatar_id::String
    url::String
    html_url::String
    followers_url::String
    following_url::String
    gists_url::String
    starred_url::String
    subscriptions_url::String
    organizations_url::String
    repos_url::String
    events_url::String
    received_events_url::String
    type::String
    site_admin::Bool
    name::String
    company::String
    blog::String
    location::String
    email::String
    hireable::Bool
    bio::String
    twitter_username::String
    public_repos::Int64
    public_gists::Int64
    followers::Int64
    following::Int64
    created_at::String
    updated_at::String

    function User(;
        login::String="",
        id::Int64=0,
        node_id::String="",
        avatar_url::String="",
        gravatar_id::String="",
        url::String="",
        html_url::String="",
        followers_url::String="",
        following_url::String="",
        gists_url::String="",
        starred_url::String="",
        subscriptions_url::String="",
        organizations_url::String="",
        repos_url::String="",
        events_url::String="",
        received_events_url::String="",
        type::String="",
        site_admin::Bool=false,
        name::String="",
        company::String="",
        blog::String="",
        location::String="",
        email::String="",
        hireable::Bool=false,
        bio::String="",
        twitter_username::String="",
        public_repos::Int64=0,
        public_gists::Int64=0,
        followers::Int64=0,
        following::Int64=0,
        created_at::String="",
        updated_at::String=""
    )
        return new(
            login,
            id,
            node_id,
            avatar_url,
            gravatar_id,
            url,
            html_url,
            followers_url,
            following_url,
            gists_url,
            starred_url,
            subscriptions_url,
            organizations_url,
            repos_url,
            events_url,
            received_events_url,
            type,
            site_admin,
            name,
            company,
            blog,
            location,
            email,
            hireable,
            bio,
            twitter_username,
            public_repos,
            public_gists,
            followers,
            following,
            created_at,
            updated_at
        )
    end
end

StructTypes.StructType(::Type{User}) = StructTypes.Mutable()

function redirect_url(config::Umbrella.Configuration.Options)
    login = ""
    state = "asdfasgsfqerwrtgedf"
    allow_signup = "true"

    query = """client_id=$(config.client_id)&redirect_uri=$(config.redirect_uri)&scope=$(config.scope)&login=$(login)&state=$(state)&allow_signup=$(allow_signup)"""

    return """$(AUTH_URL)?$(query)"""
end

function token_exchange(code::String, config::Umbrella.Configuration.Options)
    headers = ["Content-Type" => "application/json"]

    body = Dict(
        "code" => code,
        "client_id" => config.client_id,
        "client_secret" => config.client_secret,
        "redirect_uri" => config.redirect_uri,
    )

    tokens = _token_exchange(TOKEN_URL, headers, JSON3.write(body))
    profile = _get_user(USER_URL, tokens.access_token)

    return tokens, profile
end

function _get_user(url::String, access_token::String)
    headers = ["Authorization" => """Bearer $(access_token)"""]
    response = HTTP.get(url, headers)
    body = String(response.body)
    return JSON3.read(remove_json_null(body), User)
end

function _token_exchange(url::String, headers::Vector{Pair{String,String}}, body::String)
    response = HTTP.post(url, headers, body)
    tokens = dict_to_struct(URIs.queryparams(String(response.body)), Tokens)
    return tokens
end

function remove_json_null(json::String)
    return replace(json, "null" => "\"\"")
end

function dict_to_struct(dict::Dict{String, String}, type)
    d = Dict(Symbol(k) => v for (k, v) in dict)
    type(;d...)
end

Umbrella.register(:github, Umbrella.OAuth2Actions(redirect_url, token_exchange))

end