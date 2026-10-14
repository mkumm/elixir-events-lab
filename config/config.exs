import Config

config :vend, ecto_repos: [Vend.Repo]

config :vend, Vend.Repo,
  database: Path.expand("../vend_#{config_env()}.db", __DIR__),
  pool_size: 5

config :logger, level: :info
