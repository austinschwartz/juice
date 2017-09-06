defmodule Docker.Rest do
  require Logger

  defp base_url() do
    host = Application.get_env(:juice, :docker_host)
    "#{host}"
  end

  defp options() do
    Application.get_env(:juice, :options, [])
  end

  defp default_headers() do
    #{:ok , hostname} = :inet.gethostname
    #Logger.debug "my hostname is #{hostname}"
    #%{"Content-Type" => "application/json", "Host" => hostname}
    %{"Content-Type" => "application/json"}
  end

  @doc """
  Send a GET request to the Docker API at the speicifed resource.
  """
  def get(resource, headers \\ default_headers(), opt \\ []) do
    Logger.debug "Sending GET request to the Docker HTTP API: #{base_url() <> resource}"
    base_url() <> resource
    |> HTTPoison.get!(headers, Keyword.merge(options(), opt))
    |> decode
  end

  @doc """
  Send a POST request to the Docker API, JSONifying the passed in data.
  """
  def post(resource, data \\ "", headers \\ default_headers(), opt \\ []) do
    Logger.debug "Sending POST request to the Docker HTTP API: #{base_url() <> resource}, #{inspect data}"
    data = Poison.encode! data
    base_url() <> resource
    |> HTTPoison.post!(data, headers, Keyword.merge(options(), opt))
    |> decode
  end

  @doc """
  Send a DELETE request to the Docker API.
  """
  def delete(resource, headers \\ default_headers(), opt \\ []) do
    Logger.debug "Sending DELETE request to the Docker HTTP API: #{resource}"
    base_url() <> resource
    |> HTTPoison.delete!(headers, Keyword.merge(options(), opt))
  end

  defp decode(%HTTPoison.Response{body: ""}) do
    Logger.debug "Empty response"
    :nil
  end

  defp decode(%HTTPoison.Response{body: body, status_code: status_code, headers: headers}) do
    Logger.debug "Decoding Docker API response: #{inspect body}"
    case Poison.decode(body) do
      {:ok, dict} -> dict
      {:error, _} -> body
    end
  end
end
