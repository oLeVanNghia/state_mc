defmodule StateMc.Mixfile do
  use Mix.Project

  def project do
    [app: :state_mc,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: description(),
     elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/dummy"]
  defp elixirc_paths(_), do: ["lib"]
    
  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: app_list(Mix.env)]
  end

  defp app_list(:test), do: app_list ++ [:ecto, :postgrex, :ex_machina]
  defp app_list(_), do: app_list
  defp app_list, do: [:logger]
    
  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, ">= 2.0.0"},
      {:postgrex,   ">= 0.0.0", only: :test},
      {:ex_machina, "~> 1.0.0", only: :test},
      {:ex_spec,    "~> 2.0.0", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE*"],
      maintainers: ["Nghia Le Van"],
      licenses: ["MIT"],
      links: %{"Github" => "git@github.com:leogi/state_mc.git"}
    ]
  end

  defp description do
    """
    StateMachine for Ecto
    """
  end
end
