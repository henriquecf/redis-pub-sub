# Redis PubSub

Leveraging an app with an existing Redis service, we are able to receive messages using Redis PubSub and stream them over using Phoenix channels over a persistent websocket connection.

To test this, there is a snippet of code in `assets/js/app.js` that connects to one of the channels and prepends the messages received to the HTML.

In order to send messages, we can run `iex -S mix phx.server` and run the following snippet:

```elixir
for i <- 1..100 do
  payload =
    Jason.encode!(%{
      model: "messages",
      record: %{
        id: "1",
        is_deleted: false,
        body: "Message #{i}"
      }
    })

  Redix.command!(Bspk.Redix, ["PUBLISH", "stream:companies:7", payload])
  :timer.sleep(i * 200)
end
```

The main modules to look for in this project are:

 - `redis_stream.ex` where we receive the messages published on Redis PubSub
 - `company_channel.ex` where we authorize the given companies to connect to its stream
 - `redis_stream/starter.ex` where we create a singleton Genserver across a cluster of Elixir apps
