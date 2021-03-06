defmodule SimpleChain.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_chain,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SimpleChain.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_abci, path: "../.."},
      {:httpoison, "~> 1.0"},
      {:keccakf1600, "~> 2.0", hex: :keccakf1600_orig},
      {:libsecp256k1, "~> 0.1.3"},
      {:merkle_patricia_tree, "~> 0.2.7"},
      {:protobuf, "~> 0.5.3"}
    ]
  end
end
