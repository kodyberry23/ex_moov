defmodule ExMoov.Middleware.MaybeRetry do
  @behaviour Tesla.Middleware

  @impl true
  def call(env, next, _options) do
    do_retry(env, next)
  end

  def do_retry(%Tesla.Env{status: status} = env, next) when status == 429 do
    delay = Tesla.get_header(env, "X-Retry-In") || "500"

    retry_opts = [
      delay: String.to_integer(delay),
      should_retry: fn _ -> true end
    ]

    Tesla.Middleware.Retry.call(env, next, retry_opts)
  end

  def do_retry(env, next) do
    Tesla.run(env, next)
  end
end
