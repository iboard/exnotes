defmodule Exnotes.MixProject do
  use Mix.Project

  def project do
    [
      app: :exnotes,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Exnotes.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:yaml_elixir, "~> 2.1"},
      {:timewrap, "~> 0.1"},
      {:ratatouille, git: "git@github.com:ndreynolds/ratatouille.git"}
    ]
  end
end
