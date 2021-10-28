defmodule BspkWeb.CompanyChannel do
  use BspkWeb, :channel

  @impl true
  def join("stream:companies:" <> company_id, _payload, socket) do
    Phoenix.Tracker.track(BspkWeb.Tracker, self(), "company", socket.assigns.sales_associate_id, %{})
    if to_string(socket.assigns.company_id) == company_id do
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
