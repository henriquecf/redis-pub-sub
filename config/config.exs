# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bspk,
  ecto_repos: [Bspk.Repo]

# Configures the endpoint
config :bspk, BspkWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: BspkWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bspk.PubSub,
  live_view: [signing_salt: "5yDBwZ31"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :bspk, Bspk.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :filter_parameters, ["password", "token"]

config :bspk, Bspk.Guardian,
  issuer: "BSPK",
  secret_key: System.get_env("BSPK_JWT_SECRET", "c5692ea90098707a70bcc12e6839fb91855b9b4d9baff3fc59e3137e061c9fbde4b1fbd5d28b9d0d7a377cd063b1d390a8076e2092004c21f19cb7f29800ec2e"),
  allowed_algos: ["HS512"]

config :bspk,
  load_repo: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
