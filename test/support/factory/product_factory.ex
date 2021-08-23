defmodule Test.Factory.ProductFactory do
  alias Sneakers23.Repo
  alias Sneakers23.Inventory.Product

  def params(overrides \\ %{}) do
    %{
      sku: "PRO_1",
      brand: "brand",
      color: "color",
      main_image_url: "url",
      name: "name",
      order: 1,
      price_usd: 100,
      released: false
    }
    |> Map.merge(overrides)
  end

  def create!(overrides \\ %{}) do
    %Product{}
    |> Product.changeset(params(overrides))
    |> Repo.insert!()
  end
end
