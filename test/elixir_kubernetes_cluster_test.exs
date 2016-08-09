defmodule ElixirKubernetesClusterTest do
  use ExUnit.Case
  doctest ElixirKubernetesCluster

  alias ElixirKubernetesCluster.Worker

  @example_response """
  {
  "items": [
    {
      "metadata": {
        "name": "haypoll-4180148772-ihj7l",
        "generateName": "haypoll-4180148772-",
        "namespace": "haypoll"
      },
      "status": {
        "phase": "Running",
        "conditions": [
          {
            "type": "Ready",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2016-08-08T17:28:34Z"
          }
        ],
        "hostIP": "10.0.3.11",
        "podIP": "10.2.85.9"
      }
    },
    {
      "metadata": {
        "name": "haypoll-4180148772-w77dp",
        "generateName": "haypoll-4180148772-",
        "namespace": "haypoll"
      },
      "status": {
        "phase": "Running",
        "conditions": [
          {
            "type": "Ready",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2016-08-08T17:38:15Z"
          }
        ],
        "hostIP": "10.0.3.11",
        "podIP": "10.2.85.10"
      }
    },
    {
      "metadata": {
        "name": "postgres-master-2251221407-s2tem",
        "generateName": "postgres-master-2251221407-",
        "namespace": "haypoll"
      },
      "status": {
        "phase": "Running",
        "conditions": [
          {
            "type": "Ready",
            "status": "True",
            "lastProbeTime": null,
            "lastTransitionTime": "2016-08-05T14:29:13Z"
          }
        ],
        "hostIP": "10.0.3.11",
        "podIP": "10.2.85.7"
      }
    }
  ]
}
"""

  setup do
    bypass = Bypass.open
    {:ok, %{bypass: bypass}}
  end

  test "check if pod list is obtained", %{bypass: bypass} do
    Bypass.expect bypass, fn request_conn ->
      assert "GET" == request_conn.method
      assert "/api/v1/namespaces/haypoll/pods" == request_conn.request_path
      Plug.Conn.resp(request_conn, 200, @example_response)
    end

    api_endpoint = "http://localhost:#{bypass.port}"
    app_namespace = "haypoll"
    pod_name = "haypoll-4180148772-ihj7l"
    pod_ips = Worker.obtain_pod_info(api_endpoint, app_namespace, pod_name)
    assert pod_ips == ["10.2.85.10"]
  end

end
