defmodule ExMs.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_ms,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      name: "Millisecond",
      source_url: "https://github.com/FrancisMurillo/ex_ms",
      homepage_url: "https://github.com/FrancisMurillo/ex_ms",
      docs: [
        main: "Millisecond",
        extras: ["README.md"]
      ]
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      description: "A tiny library to parse human readable formats into milliseconds.",
      maintainers: ["Francis Murillo"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/FrancisMurillo/ex_ms"}
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:timex, "~> 3.5", optional: true},
      {:ex_doc, "~> 0.18", only: :dev},
      {:credo, "~> 1.4.1", only: [:dev, :test], runtime: false},
      {:propcheck, "~> 1.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
