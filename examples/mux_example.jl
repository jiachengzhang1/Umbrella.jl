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
  page("/protected", respond("Congrats, You signed in Successfully!")),
  Mux.notfound()
)

serve(http, 3000)
