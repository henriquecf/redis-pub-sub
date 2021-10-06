defmodule BspkWeb.PageController do
  use BspkWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
