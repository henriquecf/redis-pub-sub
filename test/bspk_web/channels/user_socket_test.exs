defmodule BspkWeb.UserSocketTest do
  use ExUnit.Case, async: true

  test "it connects with right token" do
    {:ok, token, _claims} = Bspk.Guardian.encode_and_sign(%{}, %{sales_associate_id: 1, company_id: 6, store_id: 45})
    assert {:ok, %Phoenix.Socket{assigns: assigns}} = BspkWeb.UserSocket.connect(%{"token" => token}, %Phoenix.Socket{}, nil)
    assert assigns.sales_associate_id == 1
    assert assigns.company_id == 6
    assert assigns.store_id == 45
  end

  test "it does not connect with wrong token" do
    {:ok, token, _claims} = Bspk.Guardian.encode_and_sign(%{}, %{sales_associate_id: 1, company_id: 6, store_id: 45})
    assert {:error, :invalid_token} = BspkWeb.UserSocket.connect(%{"token" => token <> "wrong"}, %Phoenix.Socket{}, nil)
  end

  test "it does not accept a expired token" do
    {:ok, token, _claims} = Bspk.Guardian.encode_and_sign(%{}, %{sales_associate_id: 1, company_id: 6, store_id: 45}, ttl: {-1, :hour})
    assert {:error, :token_expired} = BspkWeb.UserSocket.connect(%{"token" => token}, %Phoenix.Socket{}, nil)
  end
end
