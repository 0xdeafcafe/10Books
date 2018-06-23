defmodule LibTen.Products.Emails do
  import Bamboo.Email

  use Bamboo.Phoenix, view: LibTenWeb.ProductsView

  alias LibTen.Products.Product
  alias LibTen.Accounts.User

  @default_endpoint LibTenWeb.Endpoint

  def product_has_been_returned(%Product{} = product, %User{} = user) do
    new_email()
    |> to(user.email)
    |> from(get_from())
    |> subject("📚 \"#{product.title}\" is now available")
    |> render("product_has_been_returned.html", %{
      product: product,
      conn: @default_endpoint
    })
  end

  def request_product_return(%Product{} = product) do
    new_email()
    |> to(product.used_by.user.email)
    |> from(get_from())
    |> subject("🚨🚨 Please return \"#{product.title}\" 🚨🚨")
    |> render("request_product_return.html", %{
      product: product,
      return_subscribers_count: length(product.used_by.return_subscribers)
    })
  end

  defp get_from do
    from_email = Application.fetch_env!(:lib_ten, :smtp_sender_email)
    {"10Books", from_email}
  end
end
