defmodule Nautsladder.Repo do
  use Ecto.Repo,
    otp_app: :nautsladder,
    adapter: Ecto.Adapters.Postgres
end
