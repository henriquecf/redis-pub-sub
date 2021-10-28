defmodule Bspk.Guardian do
  use Guardian, otp_app: :bspk

  def subject_for_token(_, %{"sales_associate_id" => sales_associate_id}) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(sales_associate_id)
    {:ok, sub}
  end
  def subject_for_token(_, _) do
    {:error, :claims_must_have_sales_associate_id}
  end

  def resource_from_claims(%{"sales_associate_id" => sales_associate_id, "company_id" => company_id, "store_id" => store_id}) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In above `subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    resource = %{
      sales_associate_id: sales_associate_id,
      company_id: company_id,
      store_id: store_id
    }
    {:ok,  resource}
  end
  def resource_from_claims(_claims) do
    {:error, :claims_must_have_store_id_and_company_id}
  end
end
