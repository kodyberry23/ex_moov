defmodule ExMoov.Accounts.Token do
  use ExMoov.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:token, :string)
  end

  def map_resonse(params) do
    %__MODULE__{}
    |> cast(params, [:token])
    |> apply_changes()
  end
end
