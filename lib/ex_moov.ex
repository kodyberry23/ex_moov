defmodule ExMoov do
  alias ExMoov.Client

  def request(params, client_opts \\ %{}) do
    url = Map.get(params, :url, "")
    method = Map.get(params, :method, :get)
    body = Map.get(params, :body)

    req_params = [url: url, method: method, body: body]

    Tesla.request(Client.new(client_opts), req_params)
  end

  def handle_response({:ok, %Tesla.Env{status: status, body: body}} = _response, module)
  when status in 200..299 do
    module.map_response(body)
  end

  def handle_response(response, _module) do
    response
  end
end
