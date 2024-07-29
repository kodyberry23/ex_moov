defmodule ExMoov.Accounts do
  @moduledoc """
  # Accounts

  Accounts represent a legal entity (either a business or an individual) in Moov. You can create an account for yourself or set up accounts for others, requesting different capabilities depending on what you need to be able to do with that account. You can retrieve an account to get details on the business or individual account holder,
  such as an email address or employer identification number (EIN). Based on the type of account and its requested capabilities, we have certain verification requirements. To see what capabilities that account has, you can use the GET capability endpoint.
  When you sign up for the Moov Dashboard, you will have a facilitator account which can be used to facilitate money movement between other accounts. A facilitator account will not show up in your list of accounts and cannot be created via API. To update your facilitator account information, use the settings page of the Moov Dashboard.
  You can disconnect an account within the account’s settings in the Moov Dashboard. This action cannot be undone. When an account is disconnected, the account’s history and wallet is retained, but transfers cannot be submitted, and no actions can be taken on the account. See the Dashboard guide for more information. It is not possible to permanently delete an account.

  See Moov [Accounts](https://docs.moov.io/api/moov-accounts/accounts/) for additional info.
  """


  @doc """
  You can create business or individual accounts for your users (i.e., customers, merchants) by passing the required information to Moov. Requirements differ per account type and requested capabilities.

  If you’re requesting the wallet, send-funds, collect-funds, or card-issuing capabilities, you’ll need to:

  Send Moov the user platform terms of service agreement acceptance. This can be done upon account creation, or by patching the account using the termsOfService field.
  If you’re creating a business account with the business type llc, partnership, or privateCorporation, you’ll need to:

  Provide business representatives after creating the account.
  Patch the account to indicate that business representative ownership information is complete.
  Visit our documentation to read more about creating accounts and verification requirements.

  Note that the mode field (for production or sandbox) is only required when creating a facilitator account. All non-facilitator account requests will ignore the mode field and be set to the calling facilitator’s mode.

  To use this endpoint from the browser, you will need to specify the /accounts.write scope when generating a token.
  """
  def create(body, client_opts) do
    body = %{
      url: "/accounts",
      method: :post,
      body: body
    }

    ExMoov.request(body, client_opts)
  end
end
