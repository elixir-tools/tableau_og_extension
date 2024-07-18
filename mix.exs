defmodule TableauOgExtension.MixProject do
  use Mix.Project

  @source_url "https://github.com/elixir-tools/tableau_og_extension"

  def project do
    [
      app: :tableau_og_extension,
      description: "Open Graph Extension for Tableau",
      source_url: @source_url,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
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
      {:tableau, "~> 0.16"},
      {:nodejs, "~> 3.1"}
    ]
  end

  defp package do
    [
      maintainers: ["Mitchell Hanberg"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url,
        Sponsor: "https://github.com/sponsors/mhanberg"
      },
      files: ~w(lib priv LICENSE mix.exs README.md .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "Tableau.OgExtension"
    ]
  end
end
