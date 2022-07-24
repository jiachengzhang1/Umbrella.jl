module Configuration

abstract type ProviderOptions end

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