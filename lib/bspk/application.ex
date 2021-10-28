defmodule Bspk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    redis_uri = System.get_env("REDIS_URL", "redis://localhost:6379")
    socket_opts = Application.get_env(:bspk, :redix_socket_opts)

    children = [
      # Start the Telemetry supervisor
      BspkWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bspk.PubSub},
      # Start the Endpoint (http/https)
      BspkWeb.Endpoint,
      # Start a worker by calling: Bspk.Worker.start_link(arg)
      %{
        id: Bspk.Redix,
        start: {Redix, :start_link, [redis_uri, [name: Bspk.Redix, socket_opts: socket_opts]]}
      },
      %{
        id: Bspk.Redix.PubSub,
        start: {Redix.PubSub, :start_link, [redis_uri, [name: Bspk.Redix.PubSub, socket_opts: socket_opts]]},
        restart: :permanent,
        shutdown: 5_000,
        type: :worker
      },
      {Bspk.RedisStream.Starter, []},
      {BspkWeb.Tracker, [name: BspkWeb.Tracker, pubsub_server: Bspk.PubSub]}
    ]

    children = if Application.get_env(:bspk, :load_repo) do
      [Bspk.Repo | children]
    else
      children
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bspk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BspkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
