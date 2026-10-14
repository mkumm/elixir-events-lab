defmodule Vend.MixProject do
  use Mix.Project

  def project do
    [
      app: :vend,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Vend.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.12"},
      {:ecto_sqlite3, "~> 0.17"},
      {:jason, "~> 1.4"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      reset: ["ecto.drop", "ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"]
    ]
  end
end
