defmodule Sneakers23.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Sneakers23.Repo,
      # Start the Telemetry supervisor
      Sneakers23Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Sneakers23.PubSub},
      # Start the Endpoint (http/https)
      Sneakers23Web.Endpoint,
      # Start a worker by calling: Sneakers23.Worker.start_link(arg)
      # {Sneakers23.Worker, arg}
      Sneakers23.Inventory
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sneakers23.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Sneakers23Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
