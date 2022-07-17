using Genie, Genie.Router, Genie.Renderer
using Umbrella

const options = Configuration.Options(;
    client_id="",
    client_secret="",
    redirect_uri="http://localhost:3000/oauth2/google/callback",
    success_redirect="/yes",
    failure_redirect="/no",
    scopes=["profile", "openid", "email"]
)

const githubOptions = Configuration.Options(;
    client_id="",
    client_secret="",
    redirect_uri="http://localhost:3000/oauth2/github/callback",
    success_redirect="/yes",
    failure_redirect="/no",
    scopes=["user", "email", "profile"]
)

const facebookOptions = Configuration.Options(;
    client_id="",
    client_secret="",
    redirect_uri="http://localhost:3000/oauth2/facebook/callback",
    success_redirect="/yes",
    failure_redirect="/no",
    scopes=["user", "email", "profile"]
)

google_oauth2 = init(:google, options, Genie.Renderer.redirect)
github_oauth2 = init(:github, githubOptions, Genie.Renderer.redirect)
facebook_oauth2 = init(:facebook, facebookOptions, Genie.Renderer.redirect)

route("/") do
    return """
        <a href="/oauth2/google">Authenticate with Google</a>
        <br/>
        <a href="/oauth2/github">Authenticate with GitHub</a>
        <br/>
        <a href="/oauth2/facebook">Authenticate with Facebook</a>
    """
end

route("/oauth2/google") do
    google_oauth2.redirect()
end

route("/oauth2/github") do
    github_oauth2.redirect()
end

route("/oauth2/facebook") do
    facebook_oauth2.redirect()
end

route("/oauth2/google/callback") do
    code = Genie.params(:code, nothing)
    function verify(tokens::Google.Tokens, user::Google.User)
        println(tokens.access_token)
        println(user.email)
    end

    google_oauth2.token_exchange(code, verify)
end

route("/oauth2/github/callback") do
    code = Genie.params(:code, nothing)
    function verify(tokens::GitHub.Tokens, user::GitHub.User)
        println(tokens.access_token)
        println(user.name)
        println(user)
    end

    github_oauth2.token_exchange(code, verify)
end

route("/oauth2/facebook/callback") do
    code = Genie.params(:code, nothing)
    function verify(tokens::Facebook.Tokens, user::Facebook.User)
        println(tokens.access_token)
        println(user.first_name)
        println(user)
    end

    facebook_oauth2.token_exchange(code, verify)
end

route("/yes") do
    return "234"
end

route("/no") do
    return "no"
end

up(3000, async=false)