
const MOCK_AUTH_URL = "https://mock.com/oauth2/"

function mock_redirect(url::String, params::Nothing) url end

function mock_redirect_url(config::Configuration.Options)
  "$(MOCK_AUTH_URL)?client_id=$(config.client_id)&redirect_uri=$(config.redirect_uri)&scope=$(config.scope)"
end

function mock_token_exchange(code::String, config::Configuration.Options)
  code, config
end

function mock_verify(tokens, user)
  tokens, user
  return nothing
end

register(:mock, OAuth2Actions(mock_redirect_url, mock_token_exchange))

@testset "Init Mock Instance" begin
  redirect_uri = "http://localhost:3000/oauth2/callback"
  success_redirect = "/yes"
  failure_redirect = "/no"

  options = Configuration.Options(;
    client_id="mock_id",
    client_secret="mock_secret",
    redirect_uri=redirect_uri,
    success_redirect=success_redirect,
    failure_redirect=failure_redirect,
    scopes=["profile", "openid", "email"]
  )
  
  instance = init(:mock, options, mock_redirect)

  @test instance.redirect() == "https://mock.com/oauth2/?client_id=mock_id&redirect_uri=http://localhost:3000/oauth2/callback&scope=profile%20openid%20email"
  @test instance.token_exchange("test_code", mock_verify) == success_redirect
end
