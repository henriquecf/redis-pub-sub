defmodule BspkWeb.StoreChannel do
  use BspkWeb, :channel

  @impl true
  def join("stream:stores:" <> store_id, _payload, socket) do
    if to_string(socket.assigns.store_id) == store_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info({_event, %{"model" => model, "record" => record}}, socket) do
    push socket, "stream:" <> model, record
    {:noreply, socket}
  end
end
