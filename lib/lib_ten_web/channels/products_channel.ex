defmodule LibTenWeb.ProductsChannel do
  use Phoenix.Channel

  alias LibTen.Products
  alias LibTen.Products.Product
  alias LibTenWeb.ErrorView

  # TODO:
  # Think on refactoring data structures returned from context to have less
  # SQL queries

  def join("products", _message, socket) do
    products = Products.list_products() |> Products.to_json_map
    {:ok, %{payload: products}, socket}
  end


  def handle_in("create", %{"attrs" => attrs}, socket) do
    result = attrs
      |> Map.merge(%{"status" => Product.order_statuses[:requested]})
      |> Products.create_product()
    build_response(socket, result)
  end


  def handle_in("update", %{"id" => id, "attrs" => attrs}, socket) do
    try do
      product = Products.get_product!(id)
      build_response(socket, Products.update_product(product, attrs))
    rescue
      Ecto.NoResultsError -> reply_with_error(socket, %{type: :not_found})
    end
  end


  def handle_in("delete", %{"id" => id}, socket) do
    try do
      product = Products.get_product!(id)
      build_response(socket, Products.delete_product(product))
    rescue
      Ecto.NoResultsError -> reply_with_error(socket, %{type: :not_found})
    end
  end


  def handle_in("take", %{"id" => id}, socket) do
    product = Products.take_product(id, socket.assigns[:user_id])
    build_response(socket, product)
  end


  def handle_in("return", %{"id" => id}, socket) do
    try do
      product = Products.return_product(id, socket.assigns[:user_id])
      build_response(socket, product)
    rescue
      Ecto.NoResultsError -> reply_with_error(socket, %{type: :not_found})
    end
  end


  def handle_in("upvote", %{"id" => id}, socket) do
    try do
      product = Products.vote_for_product(id, socket.assigns[:user_id], true)
      build_response(socket, product)
    rescue
      Ecto.NoResultsError -> reply_with_error(socket, %{type: :not_found})
    end
  end


  def handle_in("downvote", %{"id" => id}, socket) do
    try do
      product = Products.vote_for_product(id, socket.assigns[:user_id], false)
      build_response(socket, product)
    rescue
      Ecto.NoResultsError -> reply_with_error(socket, %{type: :not_found})
    end
  end


  def handle_in("rate", %{"id" => id, "rating" => rating}, socket) do
    product = Products.rate_product(id, socket.assigns[:user_id], rating)
    build_response(socket, product)
  end


  # TODO: Core Review :not_found
  defp reply_with_error(socket, error) do
    response = ErrorView.render("error.json", error)
    {:reply, {:error, response}, socket}
  end

  defp build_response(socket, context_result) do
    case context_result do
      {:ok, product} ->
        response = Products.to_json_map(product)
        {:reply, {:ok, response}, socket}
      {:error, changeset} -> reply_with_error(socket, changeset)
    end
  end
end
