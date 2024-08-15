defmodule ExMoov.Transfers do
  @moduledoc """
  A transfer is the movement of money between Moov accounts, from source to destination. You can initiate a transfer to another Moov account as long as there is a linked and verified payment method.

  With Moov, you can also implement transfer groups, allowing you to associate multiple transfers together and run them sequentially. To learn more, read Moov's guide on transfer groups.

  You can simulate various RTP, push to card, ACH, and declined transfer scenarios in test mode. See Moov's test mode guide for more information.
  """

  alias ExMoov.Transfers.Transfer

  @doc """
  Move money by providing the source, destination, and amount in the request body. Read Moov's transfers overview guide to learn more.

  If you are running a server-side integration, you will use your API keys per Moov's authentication guidelines.
  """
  def create(body, client_opts \\ %{}) do
    params = %{
      method: :post,
      url: "/transfers",
      body: body
    }

    params
    |> ExMoov.request(client_opts)
    |> ExMoov.handle_response(Transfer)
  end
end
