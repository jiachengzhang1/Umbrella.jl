import HTTP

function redirect(
        url::String, params::Dict{String, Any}=nothing,
        status::Int = 302
    )

    # Set redirect parameters (if they exist)
    if ! isnothing(params)
        uri = HTTP.URI(
            path = url,
            query = params
        )
        url = string(uri)
    end

    # Redirect to url
    headers = Dict{String, String}(
        "Location" => url
    )
    HTTP.Response(status, [h for h in headers])
end
