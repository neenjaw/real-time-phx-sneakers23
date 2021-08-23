defmodule Sneakers23Web.ProductController do
  use Sneakers23Web, :controller

  def index(conn, _params) do
    {:ok, products} = Sneakers23.Inventory.get_complete_products()

    conn
    |> assign(:products, products)
    |> put_resp_header("Cache-Control", "no-store, must-revalidate")
    |> render("index.html")
  end
end
