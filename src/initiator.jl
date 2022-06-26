
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

function init(type::Symbol, config::Configuration.Options, redirect_hanlder::Function)
    actions = oauth2_typed_actions[type]
    return OAuth2(
        type,
        function ()
            url = actions[:redirect_url](config)
            redirect_hanlder(url)
        end,
        function (code::String, verify::Function)
            tokens, profile = actions[:token_exchange](code, config)
            if tokens === nothing || profile === nothing
                return redirect_hanlder(config.failure_redirect)
            end
            verify(tokens, profile)
            redirect_hanlder(config.success_redirect)
        end
    )
end