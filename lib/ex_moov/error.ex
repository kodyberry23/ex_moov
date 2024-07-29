defmodule ExMoov.InvalidPublicKeyError do
  defexception message: """
               A `:public_key` is required in order to make calls to Moov.
               Please configure `:public_key` within your config.exs file.

               config :ex_moov, public_key: "your_public_key"
               """

  @type t() :: %__MODULE__{
          message: binary()
        }
end

defmodule ExMoov.InvalidSecretKeyError do
  defexception message: """
               A `:secret_key` is required in order to make calls to Moov.
               Please configure `:secret_key` within your config.exs file.

               config :ex_moov, secret_key: "your_secret_key"
               """

  @type t() :: %__MODULE__{
          message: binary()
        }
end
