
"""
    OAuth2(type, redirect, token_exchange)

Represents an OAuth2 with fields:

- `type::Symbol` OAuth 2 provider
- `redirect::Function` Generates the redirect URL and redirects users to provider's OAuth 2 server to initiate the authentication and authorization process.
- `token_exchange::Function` Use `code` responded by the OAuth 2 server to exchange an access token, and get user profile using the access token.

`redirect` and `token_exchange` functions are produced by `init` function, they are configured for a specific OAuth 2 provider, example usage:

```julia
const options = Configuration.Options(
    # fill in the values
)
const oauth2 = Umbrella.init(:google, options)

# perform redirect
oauth2.redirect()

# handle token exchange
oauth2.token_exchange(code, verify)
```
"""
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

"""
    register(type::Symbol, oauth2_actions::OAuth2Actions)

Register a newly implemented OAuth 2 provider.
"""
function register(type::Symbol, oauth2_actions::OAuth2Actions)
    oauth2_typed_actions[type] = Dict(
        :redirect => oauth2_actions.redirect,
        :token_exchange => oauth2_actions.token_exchange
    )
end

"""
    init(type::Symbol, config::Configuration.Options)

Initiate an OAuth 2 instance for the given provider.
"""
function init(type::Symbol, config::Configuration.Options, redirect_hanlder::Function = redirect)
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
