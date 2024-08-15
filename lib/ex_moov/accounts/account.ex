defmodule ExMoov.Accounts.Account do
  use ExMoov.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:accountID, :string)
    field(:accountType, Ecto.Enum, values: [:business, :individual])

    embeds_many :capabilities, Capability, primary_key: false do
      field(:capability, :string)
      field(:status, Ecto.Enum, values: [:enabled, :disabled, :pending, :in_review])
    end

    field(:createdOn, :utc_datetime)

    embeds_one :customerSupport, CustomerSupport, primary_key: false do
      embeds_one :address, Address, primary_key: false do
        field(:addressLine1, :string)
        field(:addressLine2, :string)
        field(:city, :string)
        field(:country, :string)
        field(:postalCode, :string)
        field(:stateOrProvince, :string)
      end

      field(:email, :string)

      embeds_one :phone, Phone, primary_key: false do
        field(:countryCode, :string)
        field(:number, :string)
      end

      field(:website, :string)
    end

    field(:disconnectedOn, :utc_datetime)
    field(:displayName, :string)
    field(:foreignID, :string)
    field(:metadata, :map)
    field(:mode, Ecto.Enum, values: [:production, :sandbox])

    embeds_one :profile, Profile, primary_key: false do
      embeds_one :business, Business, primary_key: false do
        embeds_one :address, Address, primary_key: false do
          field(:addressLine1, :string)
          field(:addressLine2, :string)
          field(:city, :string)
          field(:country, :string)
          field(:postalCode, :string)
          field(:stateOrProvince, :string)
        end

        field(:businessType, Ecto.Enum,
          values: [
            :llc,
            :partnership,
            :privateCorporation,
            :soleProprietorship,
            :unincorporatedAssociation,
            :trust,
            :publicCorporation,
            :unincorporatedNonProfit,
            :incorporatedNonProfit,
            :governmentEntity
          ]
        )

        field(:description, :string)
        field(:doingBusinessAs, :string)
        field(:email, :string)

        embeds_one :industryCodes, IndustryCodes, primary_key: false do
          field(:mcc, :string)
          field(:naics, :string)
          field(:sic, :string)
        end

        field(:legalBusinessName, :string)
        field(:ownersProvided, :boolean)

        embeds_one :phone, Phone, primary_key: false do
          field(:countryCode, :string)
          field(:number, :string)
        end

        field(:primaryRegulator, Ecto.Enum, values: [:OCC, :FDIC, :NCUA, :FRB])
        field(:representatives, {:array, :map})
        field(:taxIDProvided, :boolean)
        field(:website, :string)
      end

      embeds_one :individual, Individual, primary_key: false do
        embeds_one :address, Address, primary_key: false do
          field(:addressLine1, :string)
          field(:addressLine2, :string)
          field(:city, :string)
          field(:country, :string)
          field(:postalCode, :string)
          field(:stateOrProvince, :string)
        end

        field(:birthDateProvided, :boolean)
        field(:email, :string)
        field(:governmentIDProvided, :boolean)

        embeds_one :name, Name, primary_key: false do
          field(:firstName, :string)
          field(:lastName, :string)
          field(:middleName, :string)
          field(:suffix, :string)
        end

        embeds_one :phone, Phone, primary_key: false do
          field(:countryCode, :string)
          field(:number, :string)
        end
      end
    end

    embeds_one :settings, Settings, primary_key: false do
      embeds_one :achPayment, ACHPayment, primary_key: false do
        field(:companyName, :string)
      end

      embeds_one :cardPayment, CardPayment, primary_key: false do
        field(:statementDescriptor, :string)
      end
    end

    embeds_one :termsOfService, TermsOfService, primary_key: false do
      field(:acceptedDate, :utc_datetime)
      field(:acceptedIP, :string)
    end

    field(:updatedOn, :utc_datetime)

    embeds_one :verification, Verification, primary_key: false do
      field(:details, Ecto.Enum,
        values: [
          :failedAutoVerify,
          :docDobMismatch,
          :docNameMismatch,
          :docAddressMismatch,
          :docNumberMismatch,
          :docIncomplete,
          :docFailedRisk,
          :potentialAccountSanctionsMatch,
          :potentialRepresentativeSanctionsMatch,
          :failedOther
        ]
      )

      embeds_many :documents, Document, primary_key: false do
        field(:contentType, :string)
        field(:documentID, :string)
        field(:parseErrors, {:array, :string})

        field(:type, Ecto.Enum,
          values: [:DriversLicense, :Passport, :UtilityBill, :BankStatement]
        )

        field(:uploadedAt, :utc_datetime)
      end

      field(:status, Ecto.Enum,
        values: [:unverified, :pending, :resubmit, :review, :verified, :failed]
      )

      field(:verificationStatus, Ecto.Enum, values: [:unverified, :pending, :verified, :errored])
    end
  end

  def map_response(params) do
    %__MODULE__{}
    |> cast(params, [
      :accountID,
      :accountType,
      :createdOn,
      :disconnectedOn,
      :displayName,
      :foreignID,
      :metadata,
      :mode,
      :updatedOn
    ])
    |> cast_embed(:capabilities, with: &capability_changeset/2)
    |> cast_embed(:customerSupport, with: &customer_support_changeset/2)
    |> cast_embed(:profile, with: &profile_changeset/2)
    |> cast_embed(:settings, with: &settings_changeset/2)
    |> cast_embed(:termsOfService, with: &terms_of_service_changeset/2)
    |> cast_embed(:verification, with: &verification_changeset/2)
    |> apply_changes()
  end

  defp capability_changeset(schema, params) do
    schema
    |> cast(params, [:capability, :status])
  end

  defp customer_support_changeset(schema, params) do
    schema
    |> cast(params, [:email, :website])
    |> cast_embed(:address, with: &address_changeset/2)
    |> cast_embed(:phone, with: &phone_changeset/2)
  end

  defp profile_changeset(schema, params) do
    schema
    |> cast(params, [])
    |> cast_embed(:business, with: &business_changeset/2)
    |> cast_embed(:individual, with: &individual_changeset/2)
  end

  defp settings_changeset(schema, params) do
    schema
    |> cast(params, [])
    |> cast_embed(:achPayment, with: &ach_payment_changeset/2)
    |> cast_embed(:cardPayment, with: &card_payment_changeset/2)
  end

  defp terms_of_service_changeset(schema, params) do
    schema
    |> cast(params, [:acceptedDate, :acceptedIP])
  end

  defp verification_changeset(schema, params) do
    schema
    |> cast(params, [:details, :status, :verificationStatus])
    |> cast_embed(:documents, with: &document_changeset/2)
  end

  defp address_changeset(schema, params) do
    schema
    |> cast(params, [:addressLine1, :addressLine2, :city, :country, :postalCode, :stateOrProvince])
  end

  defp phone_changeset(schema, params) do
    schema
    |> cast(params, [:countryCode, :number])
  end

  defp business_changeset(schema, params) do
    schema
    |> cast(params, [
      :businessType,
      :description,
      :doingBusinessAs,
      :email,
      :legalBusinessName,
      :ownersProvided,
      :primaryRegulator,
      :representatives,
      :taxIDProvided,
      :website
    ])
    |> cast_embed(:address, with: &address_changeset/2)
    |> cast_embed(:industryCodes, with: &industry_codes_changeset/2)
    |> cast_embed(:phone, with: &phone_changeset/2)
  end

  defp industry_codes_changeset(schema, params) do
    schema
    |> cast(params, [:mcc, :naics, :sic])
  end

  defp individual_changeset(schema, params) do
    schema
    |> cast(params, [:birthDateProvided, :email, :governmentIDProvided])
    |> cast_embed(:address, with: &address_changeset/2)
    |> cast_embed(:name, with: &name_changeset/2)
    |> cast_embed(:phone, with: &phone_changeset/2)
  end

  defp name_changeset(schema, params) do
    schema
    |> cast(params, [:firstName, :lastName, :middleName, :suffix])
  end

  defp ach_payment_changeset(schema, params) do
    schema
    |> cast(params, [:companyName])
  end

  defp card_payment_changeset(schema, params) do
    schema
    |> cast(params, [:statementDescriptor])
  end

  defp document_changeset(schema, params) do
    schema
    |> cast(params, [:contentType, :documentID, :parseErrors, :type, :uploadedAt])
  end
end
