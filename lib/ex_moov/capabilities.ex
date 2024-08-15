defmodule ExMoov.Capabilities do
  @moduledoc """
  # Capabilities
  Capabilities determine what a Moov account can do. Each capability has specific requirements, depending on risk and compliance standards associated with different account activities.
  For example, there are more information requirements for a business that wants to charge other accounts than for an individual who simply wants to receive funds.

  When you request a capability, we list the information requirements for that capability. Once you submit the required information, we need to verify the data. Because of this, a requested capability may not immediately become active.
  Note, if an account requests and is approved for send-funds or collect-funds, the wallet capability is automatically enabled as well. For more detailed information on capabilities and capability IDs, read Moov's capabilities guide.
  """

  alias ExMoov.Capabilities.Capability

  @doc """
  Request capabilities for a specific account. Read Moov's capabilities guide to learn more.
  """
  def request_capabilities(account_id, body, client_opts \\ %{}) do
    params = %{
      url: "/accounts/#{account_id}/capabilities",
      method: :post,
      body: body
    }

    params
    |> ExMoov.request(client_opts)
    |> ExMoov.handle_response(Capability)
  end
end
