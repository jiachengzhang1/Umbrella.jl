
mutable struct OAuth2
    type::Symbol
    redirect::Function
    token_exchange::Function
end

const oauth2_typed_actions = Dict(
    :google => Dict(
        :redirect_url => Google.redirect_url,
        :token_exchange => Google.token_exchange
    ),
    :github => Dict(
        :redirect_url => GitHub.redirect_url,
        :token_exchange => GitHub.token_exchange
    )
)

function init(type::Symbol, config::Configuration.Options)
    actions = oauth2_typed_actions[type]
    return OAuth2(
        type,
        function ()
            url = actions[:redirect_url](config)
            Genie.Renderer.redirect(url)
        end,
        function (verify::Function)
            code = Genie.params(:code, nothing)
            tokens, profile = actions[:token_exchange](code, config)
            verify(tokens, profile)
            Genie.Renderer.redirect(config.success_redirect)
        end
    )
end