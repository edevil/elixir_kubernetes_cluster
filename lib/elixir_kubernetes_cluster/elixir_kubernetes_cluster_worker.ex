defmodule ElixirKubernetesCluster.Worker do
  @moduledoc """
  Contacts Kubernetes to check the list of node IPs
  """
  use GenServer
  require Logger

  @doc """
  Contacts the Kubernetes API to obtain a list of pods of the desired namespace.
  Next it filters the pods and maps them to their IP address.
  """
  def obtain_pod_info(api_endpoint, app_namespace, pod_name) do
    %{"pod_prefix" => pod_prefix} =
      Regex.named_captures(~r/^(?<pod_prefix>.+?)-(?<dep_id>[^-]+)-(?<pod_id>[^-]+)$/, pod_name)

    api_url = "#{api_endpoint}/api/v1/namespaces/#{app_namespace}/pods"
    %HTTPoison.Response{:body => body, :status_code => 200} = HTTPoison.get!(api_url)
    %{"items" => items} = Poison.decode!(body)
    app_pods = Enum.filter(items, fn(pod) -> pod["metadata"]["name"] != pod_name && String.starts_with?(pod["metadata"]["name"], pod_prefix) && pod["status"]["phase"] == "Running" end)
    pod_ips = Enum.map(app_pods, fn(pod) -> pod["status"]["podIP"] end)
    pod_ips
  end

  @doc """
  Given a list of pod_ips, it tries to connect to all of them.
  """
  def connect_to_pods(pod_ips, app_namespace) do
    for pod_ip <- pod_ips do
      Logger.debug("Connecting to node running on IP #{pod_ip}")
      case Node.connect :"#{app_namespace}@#{pod_ip}" do
        true -> Logger.debug("Successfully connected to node running on IP #{pod_ip}")
        false -> Logger.warn("Could not connect to node running on IP #{pod_ip}")
      end
    end
  end

  def start_link() do
    api_endpoint = Application.get_env(:elixir_kubernetes_cluster, :kube_api_endpoint)
    app_namespace_env = Application.get_env(:elixir_kubernetes_cluster, :app_namespace_env)
    pod_name_env = Application.get_env(:elixir_kubernetes_cluster, :pod_name_env)
    app_namespace = System.get_env(app_namespace_env)
    pod_name = System.get_env(pod_name_env)

    cond do
      not Node.alive? ->
        Logger.warn("Local node is not alive, so cannot be part of a distributed system.")
      not app_namespace or not pod_name ->
        Logger.info("Did not detect Kubernetes environment")
      true ->
        api_endpoint
        |> obtain_pod_info(app_namespace, pod_name)
        |> connect_to_pods(app_namespace)
    end

    GenServer.start_link(__MODULE__, nil, [])
  end

end
