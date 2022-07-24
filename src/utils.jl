import HTTP

function redirect(url::String, status::Int = 302)
  headers = Dict{String, String}(
    "Location" => url
  )

  HTTP.Response(status, [h for h in headers])
end