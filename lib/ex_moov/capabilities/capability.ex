defmodule ExMoov.Capabilities.Capability do
  use ExMoov.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:accountID, :string)
    field(:capability, :string)
    field(:createdOn, :utc_datetime)
    field(:disabledOn, :utc_datetime)
    field(:disabledReason, :string)

    embeds_one :requirments, Requirments, primary_key: false do
      field(:currentlyDue, {:array, :string})

      embeds_many :errors, Errors, primary_key: false do
        field(:errorCode, :string)
        field(:requirment, :string)
      end
    end

    field(:status, :string)
    field(:updatedOn, :utc_datetime)
  end

  def map_response(params) do
    %__MODULE__{}
    |> cast(params, [
      :accountID,
      :capability,
      :createdOn,
      :disabledOn,
      :disabledReason,
      :status,
      :updatedOn
    ])
    |> cast_embed(:requirments)
    |> apply_changes()
  end

  def requirments_changeset(schema, params) do
    schema
    |> cast(params, [:currentlyDue])
    |> cast_embed(:errors, with: &errors_changeset/2)
  end

  def errors_changeset(schema, params) do
    cast(schema, params, [:errorCode, :requirment])
  end
end
