# Umbrella

Umbrella is a simple Julia authentication plugin, it supports Google and GitHub OAuth2 with more to come. Umbrella integrates with Julia web framework such as [Genie.jl](https://github.com/GenieFramework/Genie.jl), [Oxygen.jl](https://github.com/ndortega/Oxygen.jl) or [Mux.jl](https://github.com/JuliaWeb/Mux.jl) effortlessly.

## Prerequisite
Before using the plugin, you need to obtain OAuth 2 credentials, see [Google Identity Step 1](https://developers.google.com/identity/protocols/oauth2#1.-obtain-oauth-2.0-credentials-from-the-dynamic_data.setvar.console_name-.), [GitHub: Creating an OAuth App](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) for details.

## Installation

```julia
pkg> add Umbrella
```

## Examples

### Genie.jl
Add Google OAuth2 to your web application
```julia
using Genie
using Genie.Router
using Genie.Renderer
using Umbrella

const options = Configuration.Options(;
    client_id="", # client id from Google API Console
    client_secret="", # secret from Google API Console
    redirect_uri="http://localhost:3000/oauth2/google/callback",
    success_redirect="/protected",
    failure_redirect="/no",
    scopes=["profile", "openid", "email"]
)

const google_oauth2 = Umbrella.init(:google, options, Genie.Renderer.redirect)

route("/") do
    return """<a href="/oauth2/google">Authenticate with Google</a>"""
end

route("/oauth2/google") do
    # this handles the Google oauth2 redirect in the background
    google_oauth2.redirect()
end

route("/oauth2/google/callback") do
    code = Genie.params(:code, nothing)
    # handle tokens and user details
    function verify(tokens::Google.Tokens, user::Google.User)
        println(tokens.access_token)
        println(tokens.refresh_token)
        println(user.email)
    end

    google_oauth2.token_exchange(code, verify)
end

route("/protected") do
  "Congrets, You signed in Successfully!"
end

up(3000, async=false)
```

### Oxygen.jl
```julia
using Oxygen
using Umbrella
using HTTP

const oauth_path = "/oauth2/google"
const oauth_callback = "/oauth2/google/callback"

const options = Configuration.Options(;
    client_id="", # client id from Google API Console
    client_secret="", # secret from Google API Console
    redirect_uri="http://127.0.0.1:8080$(oauth_callback)",
    success_redirect="/protected",
    failure_redirect="/no",
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

  # handle tokens and user details
  google_oauth2.token_exchange(code, 
    function (tokens::Google.Tokens, user::Google.User)
      println(tokens.access_token)
      println(tokens.refresh_token)
      println(user.email)
    end
  )
end

@get "/protected" function()
  "Congrets, You signed in Successfully!"
end

# start the web server
serve()
```
