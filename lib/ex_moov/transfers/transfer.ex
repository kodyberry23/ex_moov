defmodule ExMoov.Transfers.Transfer do
  use ExMoov.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:amount_currency, :string)
    field(:amount_value, :integer)
    field(:completedOn, :utc_datetime)
    field(:createdOn, :utc_datetime)
    field(:description, :string)
    field(:status, :string)
    field(:transferID, :string)

    embeds_one :destination, Destination, primary_key: false do
      embeds_one :account, Account, primary_key: false do
        field(:accountID, :string)
        field(:displayName, :string)
        field(:email, :string)
      end

      embeds_one :achDetails, ACHDetails, primary_key: false do
        field(:companyEntryDescription, :string)
        field(:completedOn, :utc_datetime)
        field(:correctedOn, :utc_datetime)

        embeds_one :correction, Correction, primary_key: false do
          field(:code, :string)
          field(:description, :string)
          field(:reason, :string)
        end

        field(:initiatedOn, :utc_datetime)
        field(:originatedOn, :utc_datetime)
        field(:originatingCompanyName, :string)

        embeds_one :return, Return, primary_key: false do
          field(:code, :string)
          field(:description, :string)
          field(:reason, :string)
        end

        field(:returnedOn, :utc_datetime)
        field(:secCode, :string)
        field(:status, :string)
        field(:traceNumber, :string)
      end

      embeds_one :applePay, ApplePay, primary_key: false do
        field(:brand, :string)
        field(:cardDisplayName, :string)
        field(:cardType, :string)

        embeds_one :expiration, Expiration, primary_key: false do
          field(:month, :string)
          field(:year, :string)
        end

        field(:fingerprint, :string)
      end

      embeds_one :bankAccount, BankAccount, primary_key: false do
        field(:bankAccountID, :string)
        field(:bankAccountType, :string)
        field(:bankName, :string)

        embeds_one :exceptionDetails, ExceptionDetails, primary_key: false do
          field(:achReturnCode, :string)
          field(:description, :string)
          field(:rtpRejectionCode, :string)
        end

        field(:fingerprint, :string)
        field(:holderName, :string)
        field(:holderType, :string)
        field(:lastFourAccountNumber, :string)
        field(:routingNumber, :string)
        field(:status, :string)
        field(:statusReason, :string)
        field(:updatedOn, :utc_datetime)
      end

      embeds_one :card, Card do
        embeds_one :billingAddress, BillingAddress, primary_key: false do
          field(:addressLine1, :string)
          field(:addressLine2, :string)
          field(:city, :string)
          field(:country, :string)
          field(:postalCode, :string)
          field(:stateOrProvince, :string)
        end

        field(:bin, :string)
        field(:brand, :string)

        embeds_one :cardAccountUpdater, CardAccountUpdater, primary_key: false do
          field(:updateType, :string)
          field(:updatedOn, :utc_datetime)
        end

        field(:cardCategory, :string)
        field(:cardID, :string)
        field(:cardOnFile, :boolean)
        field(:cardType, :string)

        embeds_one :cardVerification, CardVerification, primary_key: false do
          embeds_one :accountName, AccountName, primary_key: false do
            field(:firstName, :string)
            field(:fullName, :string)
            field(:lastName, :string)
            field(:middleName, :string)
          end

          field(:addressLine1, :string)
          field(:cvv, :string)
          field(:postalCode, :string)
        end

        field(:commercial, :boolean)
        field(:domesticPullFromCard, :string)
        field(:domesticPushToCard, :string)

        embeds_one :expiration, Expiration, primary_key: false do
          field(:month, :string)
          field(:year, :string)
        end

        field(:fingerprint, :string)
        field(:holderName, :string)
        field(:issuer, :string)
        field(:issuerCountry, :string)
        field(:issuerPhone, :string)
        field(:issuerURL, :string)
        field(:lastFourCardNumber, :string)
        field(:merchantAccountID, :string)
        field(:regulated, :boolean)
      end
    end
  end

  def map_response(params) do
    %__MODULE__{}
    |> cast(params, [
      :amount_currency,
      :amount_value,
      :completedOn,
      :createdOn,
      :description,
      :status,
      :transferID
    ])
    |> cast_embed(:destination, with: &destination_changeset/2)
    |> apply_changes()
  end

  defp destination_changeset(schema, params) do
    schema
    |> cast(params, [])
    |> cast_embed(:account, with: &account_changeset/2)
    |> cast_embed(:achDetails, with: &ach_details_changeset/2)
    |> cast_embed(:applePay, with: &apple_pay_changeset/2)
    |> cast_embed(:bankAccount, with: &bank_account_changeset/2)
    |> cast_embed(:card, with: &card_changeset/2)
  end

  defp account_changeset(schema, params) do
    schema
    |> cast(params, [:accountID, :displayName, :email])
  end

  defp ach_details_changeset(schema, params) do
    schema
    |> cast(params, [
      :companyEntryDescription,
      :completedOn,
      :correctedOn,
      :initiatedOn,
      :originatedOn,
      :originatingCompanyName,
      :returnedOn,
      :secCode,
      :status,
      :traceNumber
    ])
    |> cast_embed(:correction, with: &correction_changeset/2)
    |> cast_embed(:return, with: &return_changeset/2)
  end

  defp correction_changeset(schema, params) do
    schema
    |> cast(params, [:code, :description, :reason])
  end

  defp return_changeset(schema, params) do
    schema
    |> cast(params, [:code, :description, :reason])
  end

  defp apple_pay_changeset(schema, params) do
    schema
    |> cast(params, [:brand, :cardDisplayName, :cardType, :fingerprint])
    |> cast_embed(:expiration, with: &expiration_changeset/2)
  end

  defp bank_account_changeset(schema, params) do
    schema
    |> cast(params, [
      :bankAccountID,
      :bankAccountType,
      :bankName,
      :fingerprint,
      :holderName,
      :holderType,
      :lastFourAccountNumber,
      :routingNumber,
      :status,
      :statusReason,
      :updatedOn
    ])
    |> cast_embed(:exceptionDetails, with: &exception_details_changeset/2)
  end

  defp exception_details_changeset(schema, params) do
    schema
    |> cast(params, [:achReturnCode, :description, :rtpRejectionCode])
  end

  defp card_changeset(schema, params) do
    schema
    |> cast(params, [
      :bin,
      :brand,
      :cardCategory,
      :cardID,
      :cardOnFile,
      :cardType,
      :commercial,
      :domesticPullFromCard,
      :domesticPushToCard,
      :fingerprint,
      :holderName,
      :issuer,
      :issuerCountry,
      :issuerPhone,
      :issuerURL,
      :lastFourCardNumber,
      :merchantAccountID,
      :regulated
    ])
    |> cast_embed(:billingAddress, with: &billing_address_changeset/2)
    |> cast_embed(:cardAccountUpdater, with: &card_account_updater_changeset/2)
    |> cast_embed(:cardVerification, with: &card_verification_changeset/2)
    |> cast_embed(:expiration, with: &expiration_changeset/2)
  end

  defp billing_address_changeset(schema, params) do
    schema
    |> cast(params, [:addressLine1, :addressLine2, :city, :country, :postalCode, :stateOrProvince])
  end

  defp card_account_updater_changeset(schema, params) do
    schema
    |> cast(params, [:updateType, :updatedOn])
  end

  defp card_verification_changeset(schema, params) do
    schema
    |> cast(params, [:addressLine1, :cvv, :postalCode])
    |> cast_embed(:accountName, with: &account_name_changeset/2)
  end

  defp account_name_changeset(schema, params) do
    schema
    |> cast(params, [:firstName, :fullName, :lastName, :middleName])
  end

  defp expiration_changeset(schema, params) do
    schema
    |> cast(params, [:month, :year])
  end
end
