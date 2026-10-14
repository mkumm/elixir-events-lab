defmodule Vend.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Vend.Repo,
      {Registry, keys: :unique, name: Vend.Registry},
      # Part 5: uncomment once Vend.Machine exists.
      # {Vend.Machine, "lobby"}
    ]

    opts = [strategy: :one_for_one, name: Vend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
