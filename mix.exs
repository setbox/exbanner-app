defmodule ExBanner.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/dakoctba/ex_banner"

  def project do
    [
      app: :ex_banner,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description:
        "ASCII art banners for Elixir applications: startup banner from priv/banner.txt and FIGlet text rendering.",
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def cli do
    [preferred_envs: [precommit: :test]]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExBanner.Application, []}
    ]
  end

  defp deps do
    [
      {:bunt, "~> 1.0"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  defp package do
    [
      licenses: ["MIT", "BSD-3-Clause"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib priv mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end
end
