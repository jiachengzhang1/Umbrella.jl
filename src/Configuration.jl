module Configuration

abstract type ProviderOptions end

"""
    Options(client_id, client_secret, redirect_uri, success_redirect, failure_redirect, scopes, state, providerOptions)

Represents an Configuration Options with fields:

- `client_id::String` Client id from an OAuth 2 provider
- `client_secret::String` Secret from an OAuth 2 provider
- `redirect_uri::String` Determines where the API server redirects the user after the user completes the authorization flow
- `success_redirect::String` URL path when OAuth 2 successed
- `failure_redirect::String` URL path when OAuth 2 failed
- `scope::String` OAuth 2 scopes
- `state::String` Specifies any string value that your application uses to maintain state between your authorization request and the authorization server's response
"""
mutable struct Options
    client_id::String
    client_secret::String
    redirect_uri::String
    success_redirect::String
    failure_redirect::String
    scope::String
    state::Union{String, Nothing}

    providerOptions::Union{ProviderOptions, Nothing}

    function Options(;
        client_id::String="", 
        client_secret::String="", 
        redirect_uri::String="", 
        success_redirect::String="", 
        failure_redirect::String="",
        scopes::Vector{String}=[],
        state=nothing,
        providerOptions=nothing)
        return new(client_id, client_secret, redirect_uri, success_redirect, failure_redirect, join(scopes, "%20"), state, providerOptions)
    end
end

end