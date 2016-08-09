defmodule ElixirKubernetesCluster.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_kubernetes_cluster,
     version: "0.1.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "A module that automacally connects to a Kubernetes API in order to obtain the address of other nodes and connects to them.",
     package: package,
     deps: deps()]
  end

  def package do
    [
      maintainers: ["André Cruz"],
      licenses: ["GPLv3"],
      links: %{"GitHub" => "https://github.com/edevil/elixir_kubernetes_cluster"}
    ]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {ElixirKubernetesCluster, []}]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev},
     {:httpoison, "~> 0.9.0"},
     {:bypass, "~> 0.1", only: :test},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:poison, "~> 2.2"}]
  end
end
