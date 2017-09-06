defmodule Juice.Mixfile do
  use Mix.Project

  def project do
    [app: :juice,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:httpoison, :logger, :maru]]
  end

  defp deps do
    [ {:poison, "~> 3.1"},
     {:httpoison, "~> 0.13"},
     {:maru, "~> 0.12.3"}]
  end
end
