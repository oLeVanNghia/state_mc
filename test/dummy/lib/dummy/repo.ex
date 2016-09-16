defmodule Dummy.Repo do
  use Ecto.Repo, otp_app: :state_mc, adapter: Ecto.Adapters.Postgres
end
