defmodule Sneakers23.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Sneakers23.Repo,
      Sneakers23Web.Telemetry,
      {Phoenix.PubSub, name: Sneakers23.PubSub},
      Sneakers23Web.Endpoint,
      Sneakers23.Inventory,
      Sneakers23.Replication
    ]

    opts = [strategy: :one_for_one, name: Sneakers23.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Sneakers23Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
