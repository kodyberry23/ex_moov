defmodule ExMoov do
alias ExMoov.Client

def request(params, client_opts \\ %{}) do
  url = Map.get(params, :url, "")
  method = Map.get(params, :method, :get)
  body = Map.get(params, :body)

  req_params = [url: url, method: method, body: body]

  Tesla.request(Client.new(client_opts), req_params)
end
end
