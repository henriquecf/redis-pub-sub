defmodule Bspk.Repo do
  use Ecto.Repo,
    otp_app: :bspk,
    adapter: Ecto.Adapters.Postgres
end
