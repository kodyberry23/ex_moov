defmodule ExMoov.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_moov,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, ">= 0.0.0", optional: true},
      {:hackney, ">= 0.0.0", optional: true},
      {:jason, ">= 1.0.0", optional: true},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:ecto, ">= 3.0.0"}
    ]
  end
end
