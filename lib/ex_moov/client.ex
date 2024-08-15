defmodule ExMoov.Client do
  def new(opts) do
    middleware = [
      {Tesla.Middleware.BaseUrl, get_base_url(opts)},
      {Tesla.Middleware.BasicAuth,
       username: get_public_key(opts), password: get_secret_key(opts)},
      {Tesla.Middleware.Headers,
       [
         {"Content-Type", "application/json"},
         {"Accept", "application/json"}
       ]},
      Tesla.Middleware.JSON,
      ExMoov.Middleware.MaybeRetry
    ]

    Tesla.client(middleware, get_adapter(opts))
  end

  # ---------- private functions ----------
  defp get_adapter(config) do
    adapter = Map.get(config, :adapter)

    # Defaults to Hackney adapter
    adapter || Application.get_env(:ex_moov, :adapter, Tesla.Adapter.Hackney)
  end

  defp get_base_url(config) do
    base_url = Map.get(config, :base_url)

    base_url || Application.get_env(:ex_moov, :base_url, "https://api.moov.io")
  end

  defp get_public_key(config) do
    public_key = Map.get(config, :public_key) || Application.get_env(:ex_moov, :public_key)

    case public_key do
      nil ->
        raise ExMoov.InvalidPublicKeyError

      _ ->
        public_key
    end
  end

  defp get_secret_key(config) do
    secret_key = Map.get(config, :secret_key) || Application.get_env(:ex_moov, :secret_key)

    case secret_key do
      nil ->
        raise ExMoov.InvalidSecretKeyError

      _ ->
        secret_key
    end
  end
end
