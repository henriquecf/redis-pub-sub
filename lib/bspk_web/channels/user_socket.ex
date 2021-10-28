defmodule BspkWeb.UserSocket do
  use Phoenix.Socket

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  # Uncomment the following line to define a "room:*" topic
  # pointing to the `BspkWeb.RoomChannel`:
  #
  # channel "room:*", BspkWeb.RoomChannel
  #
  # To create a channel file, use the mix task:
  #
  #     mix phx.gen.channel Room
  #
  # See the [`Channels guide`](https://hexdocs.pm/phoenix/channels.html)
  # for futher details.
  channel "stream:companies:*", BspkWeb.CompanyChannel
  channel "stream:sales_associates:*", BspkWeb.SalesAssociateChannel
  channel "stream:stores:*", BspkWeb.StoreChannel


  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(params, socket, _connect_info) do
    case Bspk.Guardian.resource_from_token(params["token"]) do
      {:ok, resource, _claims} ->
        socket = socket
          |> assign(:sales_associate_id, resource.sales_associate_id)
          |> assign(:company_id, resource.company_id)
          |> assign(:store_id, resource.store_id)

        {:ok, socket}
      error ->
        error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.BspkWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.sales_associate_id}"
end
