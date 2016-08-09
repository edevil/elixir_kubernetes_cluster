# ElixirKubernetesCluster

Elixir module that uses the Kubernetes API to find the IP of other nodes of the cluster to connect to.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `elixir_kubernetes_cluster` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:elixir_kubernetes_cluster, "~> 0.1.0"}]
    end
    ```

  2. Ensure `elixir_kubernetes_cluster` is started before your application:

    ```elixir
    def application do
      [applications: [:elixir_kubernetes_cluster]]
    end
    ```

## TODO

1. Ignore our own pod when connecting to list of pods
2. Periodically compare list of pods from Kubernetes to our list of connected nodes
3. Reconcile with Kubernetes if lists differ
