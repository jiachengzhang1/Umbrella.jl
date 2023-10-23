import HTTP

function redirect(url::String, params::Dict{String, <:Any}, status::Int = 302)
    # Set redirect parameters
    uri = HTTP.URI(path = url, query = params)
    redirect(string(uri), nothing, status)
end


function redirect(url::String, ::Nothing, status::Int = 302)
    # Redirect to url
    headers = Dict{String, String}(
        "Location" => url
    )
    HTTP.Response(status, [h for h in headers])
end
