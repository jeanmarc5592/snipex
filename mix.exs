defmodule Snipex.MixProject do
  use Mix.Project

  def project do
    [
      app: :snipex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: Snipex]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Snipex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:uuid, "~> 1.1.8"},
      {:clipboard, "~> 0.2"}
    ]
  end
end
