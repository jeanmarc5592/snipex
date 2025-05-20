defmodule Snipex.Repo do
  use Ecto.Repo,
    otp_app: :snipex,
    adapter: Ecto.Adapters.SQLite3
end
