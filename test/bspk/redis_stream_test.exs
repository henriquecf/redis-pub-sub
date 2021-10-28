defmodule Bspk.RedisStreamTest do
  use BspkWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      BspkWeb.UserSocket
      |> socket("user_socket:1", %{company_id: 1, sales_associate_id: 1})
      |> subscribe_and_join(BspkWeb.CompanyChannel, "stream:companies:1")

    %{socket: socket}
  end

  test "it send a received message to be pushed to channel" do
    {:ok, conn} = Redix.start_link()
    record = %{"id" => 1}
    payload = %{"model" => "message", "record" => record}
    Redix.command!(conn, ["PUBLISH", "stream:companies:1", Jason.encode!(payload)])
    assert_receive %Phoenix.Socket.Message{event: "stream:message", payload: ^record}
  end
end
