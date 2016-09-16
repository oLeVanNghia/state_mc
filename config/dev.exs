use Mix.Config

config :state_mc, Dummy.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "macbook_041",
  password: "",
  database: "state_mc_test",
  pool_size: 10,
  port: 5432,
  priv: "priv/test/dummy/repo/"