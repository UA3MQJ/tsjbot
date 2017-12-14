defmodule TSJBot.Mixfile do
  use Mix.Project

  def project do
    [app: :tsjbot,
     version: "2017.12.13",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :poison, :bots],
     mod: {TSJBot, []}]
  end

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
      {:bots, git: "git@git.it.tender.pro:bot/bots.git"},
      {:poison, "~> 3.1"},
      {:distillery, "~> 1.5"},
    ]
  end

end
