
mutable struct OAuth2
    type::Symbol
    redirect::Function
    token_exchange::Function
end

mutable struct OAuth2Actions
    redirect::Function
    token_exchange::Function
end

const oauth2_typed_actions = Dict()

function register(type::Symbol, oauth2_actions::OAuth2Actions)
    oauth2_typed_actions[type] = Dict(
        :redirect => oauth2_actions.redirect,
        :token_exchange => oauth2_actions.token_exchange
    )
end

function init(type::Symbol, config::Configuration.Options, redirect_hanlder::Function)
    actions = oauth2_typed_actions[type]
    return OAuth2(
        type,
        function ()
            url = actions[:redirect](config)
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