module Configuration

mutable struct Options
    client_id::String
    client_secret::String
    redirect_uri::String
    success_redirect::String
    failure_redirect::String
    scope::String

    function Options(;
        client_id::String="", 
        client_secret::String="", 
        redirect_uri::String="", 
        success_redirect::String="", 
        failure_redirect::String="",
        scopes::Vector{String}=[])
        return new(client_id, client_secret, redirect_uri, success_redirect, failure_redirect, join(scopes, "%20"))
    end
end

end