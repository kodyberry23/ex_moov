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
    {:ok, module.map_response(body)}
  end

  def handle_response({:ok, %Tesla.Env{status: status, body: body}} = _response, _module)
      when status == 409 and is_bitstring(body) do
    params = %{
      status: status,
      message: body
    }

    {:error, ExMoov.Error.map_response(params)}
  end

  def handle_response(
        {:ok, %Tesla.Env{status: status, body: %{"error" => error} = _body}} = _response,
        _module
      )
      when status == 409 do
    params = %{
      status: status,
      message: error
    }

    {:error, ExMoov.Error.map_response(params)}
  end

  def handle_response({:ok, %Tesla.Env{status: status, body: %{} = body}} = _response, module)
      when status == 409 do
    {:ok, module.map_response(body)}
  end

  def handle_response(
        {:ok, %Tesla.Env{status: status, body: %{"error" => error} = _body}} = _response,
        _module
      )
      when status in 400..499 do

    params = %{
      status: status,
      message: error
    }

    {:error, ExMoov.Error.map_response(params)}
  end

  def handle_response({:ok, %Tesla.Env{status: status, body: body}} = _response, _module)
      when status in 400..499 do
    params = %{
      status: status,
      message: body
    }

    {:error, ExMoov.Error.map_response(params)}
  end

  def handle_response(response, _module) do
    response
  end
end
