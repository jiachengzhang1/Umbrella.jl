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