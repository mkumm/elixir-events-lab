defmodule Vend.Repo do
  use Ecto.Repo, otp_app: :vend, adapter: Ecto.Adapters.SQLite3
end
