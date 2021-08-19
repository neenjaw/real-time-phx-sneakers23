# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sneakers_23,
  namespace: Sneakers23,
  ecto_repos: [Sneakers23.Repo]

# Configures the endpoint
config :sneakers_23, Sneakers23Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9uxtrMJPqM2as7EPfMqqcQ5RKnT7niBrn8dcbgDxxISY+U2gr/b+0SUT1drGsyGb",
  render_errors: [view: Sneakers23Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Sneakers23.PubSub,
  live_view: [signing_salt: "ejR0f65+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
