defmodule Bspk.RedisStream do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(_opts) do
    {:ok, subscription_ref} = Redix.PubSub.psubscribe(Bspk.Redix.PubSub, "stream:*", self())

    {:ok, %{subscription_ref: subscription_ref}}
  end

  @impl true
  def handle_info(
        {:redix_pubsub, _pid, _subscription_ref, :psubscribed, %{pattern: "stream:*"}},
        state
      ) do
    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:redix_pubsub, _pid, _subscription_ref, :pmessage,
         %{channel: channel, pattern: "stream:*", payload: payload}},
        state
      ) do
    case Jason.decode(payload) do
      {:ok, decoded_payload} ->
        Phoenix.PubSub.broadcast(Bspk.PubSub, channel, {channel, decoded_payload})

      _ ->
        :error
    end

    {:noreply, state}
  end
end
