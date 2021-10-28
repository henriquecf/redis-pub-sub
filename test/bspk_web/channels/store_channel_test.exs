defmodule BspkWeb.StoreChannelTest do
  use BspkWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      BspkWeb.UserSocket
      |> socket("user_socket:1", %{store_id: 1})
      |> subscribe_and_join(BspkWeb.StoreChannel, "stream:stores:1")

    %{socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  test "does not connect if from other store" do
    assert {:error, %{reason: "unauthorized"}} = BspkWeb.UserSocket
      |> socket("user_socket:1", %{store_id: 1})
      |> subscribe_and_join(BspkWeb.StoreChannel, "stream:stores:2")
  end

  test "phoenix pubsub broadcasts are pushed to the client" do
    payload = %{"model" => "message", "record" => %{"id" => 1}}
    channel = "stream:stores:1"
    Phoenix.PubSub.broadcast(Bspk.PubSub, channel, {channel, payload})
    assert_push "stream:message", %{"id" => 1}
  end

  test "phoenix pubsub broadcasts are not pushed if from other store" do
    payload = %{"model" => "message", "record" => %{"id" => 1}}
    channel = "stream:stores:2"
    Phoenix.PubSub.broadcast(Bspk.PubSub, channel, {channel, payload})
    refute_push "stream:message", %{"id" => 1}
  end
end
