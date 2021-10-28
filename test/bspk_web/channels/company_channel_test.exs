defmodule BspkWeb.CompanyChannelTest do
  use BspkWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      BspkWeb.UserSocket
      |> socket("user_socket:1", %{company_id: 1, sales_associate_id: 1})
      |> subscribe_and_join(BspkWeb.CompanyChannel, "stream:companies:1")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  test "does not connect if from other company" do
    assert {:error, %{reason: "unauthorized"}} = BspkWeb.UserSocket
      |> socket("user_socket:1", %{company_id: 1, sales_associate_id: 1})
      |> subscribe_and_join(BspkWeb.CompanyChannel, "stream:companies:2")
  end

  test "phoenix pubsub broadcasts are pushed to the client" do
    payload = %{"model" => "message_template", "record" => %{"id" => 1}}
    channel = "stream:companies:1"
    Phoenix.PubSub.broadcast(Bspk.PubSub, channel, {channel, payload})
    assert_push "stream:message_template", %{"id" => 1}
  end

  test "phoenix pubsub broadcasts are not pushed if from other company" do
    payload = %{"model" => "message_template", "record" => %{"id" => 1}}
    channel = "stream:companies:2"
    Phoenix.PubSub.broadcast(Bspk.PubSub, channel, {channel, payload})
    refute_push "stream:message", %{"id" => 1}
  end
end
