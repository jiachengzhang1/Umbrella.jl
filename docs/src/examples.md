# Examples

Umbrella.jl supports different OAuth 2 providers, and it integrates with Julia web framework such as [Genie.jl](https://github.com/GenieFramework/Genie.jl), [Oxygen.jl](https://github.com/ndortega/Oxygen.jl) or [Mux.jl](https://github.com/JuliaWeb/Mux.jl) effortlessly, some examples to demo how it works.

## Integrate with Genie.jl

Great work [Genie.jl](https://github.com/GenieFramework/Genie.jl)

```julia
using Genie, Genie.Router
using Umbrella, Umbrella.Google

const options = Configuration.Options(;
    client_id="", # client id from Google API Console
    client_secret="", # secret from Google API Console
    redirect_uri = "http://localhost:3000/oauth2/google/callback",
    success_redirect="/protected",
    failure_redirect="/failed",
    scopes = ["profile", "openid", "email"],
    providerOptions = GoogleOptions(access_type="online")
)

google_oauth2 = init(:google, options)

route("/") do
    return "<a href='/oauth2/google'>Authenticate with Google</a>"
end

route("/oauth2/google") do
    google_oauth2.redirect()
end

route("/oauth2/google/callback") do
  code = Genie.params(:code, nothing)
  function verify(tokens::Google.Tokens, user::Google.User)
    # handle access and refresh tokens and user profile here
  end
  
  google_oauth2.token_exchange(code, verify)
end

route("/protected") do
    "Congrets, You signed in Successfully!"
end

up(3000, async=false)
```

## Integrate with Oxygen.jl

Shout out to [Oxygen.jl](https://github.com/ndortega/Oxygen.jl)

```julia
using Oxygen, Umbrella, HTTP

const oauth_path = "/oauth2/google"
const oauth_callback = "/oauth2/google/callback"

const options = Configuration.Options(;
    client_id="", # client id from Google API Console
    client_secret="", # secret from Google API Console
    redirect_uri="http://127.0.0.1:8080$(oauth_callback)",
    success_redirect="/protected",
    failure_redirect="/failed",
    scopes=["profile", "openid", "email"]
)

const google_oauth2 = Umbrella.init(:google, options)

@get "/" function ()
  return "<a href='$(oauth_path)'>Authenticate with Google</a>"
end

@get oauth_path function ()
  # this handles the Google oauth2 redirect in the background
  google_oauth2.redirect()
end

@get oauth_callback function (req)
  query_params = queryparams(req)
  code = query_params["code"]

  function verify(tokens::Google.Tokens, user::Google.User)
    # handle access and refresh tokens and user profile here
  end

  google_oauth2.token_exchange(code, verify)
end

@get "/protected" function()
  "Congrets, You signed in Successfully!"
end

# start the web server
serve()
```

## Integrate with Mux.jl

Well done [Mux.jl](https://github.com/JuliaWeb/Mux.jl)

```julia
using Mux, Umbrella, HTTP

const oauth_path = "/oauth2/google"
const oauth_callback = "/oauth2/google/callback"

const options = Configuration.Options(;
    client_id="", # client id from Google API Console
    client_secret="", # secret from Google API Console
    redirect_uri="http://127.0.0.1:3000$(oauth_callback)",
    success_redirect="/protected",
    failure_redirect="/no",
    scopes=["profile", "openid", "email"]
)

function mux_redirect(url::String, status::Int = 302)
  headers = Dict{String, String}(
    "Location" => url
  )

  Dict(
    :status => status,
    :headers => headers,
    :body => ""
  )
end

const oauth2 = Umbrella.init(:google, options, mux_redirect)

function callback(req)
  params = HTTP.queryparams(req[:uri])
  code = params["code"]

  oauth2.token_exchange(code, 
    function (tokens::Google.Tokens, user::Google.User)
      println(tokens.access_token)
      println(tokens.refresh_token)
      println(user.email)
    end
  )
end

@app http = (
  Mux.defaults,
  page("/", respond("<a href='$(oauth_path)'>Authenticate with Google</a>")),
  page(oauth_path, req -> oauth2.redirect()),
  page(oauth_callback, callback),
  page("/protected", respond("Congrets, You signed in Successfully!")),
  Mux.notfound()
)

serve(http, 3000)
```

