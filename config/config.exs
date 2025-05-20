import Config

config :snipex,
  ecto_repos: [Snipex.Repo]

config :snipex, Snipex.Repo,
  database: Path.expand("../db/#{Mix.env()}.db"),
  default_transaction_mode: :immediate
