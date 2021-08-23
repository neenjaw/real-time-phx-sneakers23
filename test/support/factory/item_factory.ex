defmodule Test.Factory.ItemFactory do
  alias Sneakers23.Repo
  alias Sneakers23.Inventory.Item
  alias Test.Factory.ProductFactory

  def params(overrides \\ %{}) do
    product_id =
      Map.get_lazy(overrides, :product_id, fn ->
        ProductFactory.create!().id
      end)

    %{
      sku: "SHU_1",
      size: "10",
      product_id: product_id
    }
    |> Map.merge(overrides)
  end

  def create!(overrides \\ %{}) do
    %Item{}
    |> Item.changeset(params(overrides))
    |> Repo.insert!()
  end
end
