defmodule RRule.MixProject do
  use Mix.Project

  def project do
    [
      app: :rrule,
      version: "0.2.0",
      elixir: "~> 1.13",
      description: "Elixir wrapper for Rust based RRule parsing",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Martin Feckie"],
      links: %{
        "Github" => "https://github.com/mfeckie/rrule"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, "0.26.0"},
      {:ex_doc, "0.28.5"}
    ]
  end
end
