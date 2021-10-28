defmodule BspkWeb.Tracker do
  use Phoenix.Tracker

  @prefix [:bspk, :presence]

  def start_link(opts) do
    opts = Keyword.merge([name: __MODULE__], opts)
    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)

    {:ok, initial_total} = Redix.command(Bspk.Redix, ["GET", "pubsub:presence:total"])
    {total, _} = Integer.parse(initial_total || "0")

    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server), total: total}}
  end

  def handle_diff(diff, state) do
    new_total = Enum.reduce(diff, state.total, fn {_, {joins, leaves}}, total ->
      total_joined = Enum.count(joins)
      total_left = Enum.count(leaves)
      total + total_joined - total_left
    end)
    :telemetry.execute(
      @prefix,
      %{total: new_total},
      %{}
    )
    for {_topic, {joins, leaves}} <- diff do
      for {key, _meta} <- joins do
        :telemetry.execute(
          @prefix ++ [:join],
          %{system_time: System.system_time()},
          %{sales_associate_id: key}
        )
      end
      for {key, _meta} <- leaves do
        :telemetry.execute(
          @prefix ++ [:leave],
          %{system_time: System.system_time()},
          %{sales_associate_id: key}
        )
      end
    end
    Redix.command(Bspk.Redix, ["SET", "pubsub:presence:total", new_total])
    {:ok, %{state | total: new_total}}
  end
end
