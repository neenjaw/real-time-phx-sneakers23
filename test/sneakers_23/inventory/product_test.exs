defmodule Sneakers23.Inventory.ProductTest do
  use Sneakers23.DataCase, async: true
  alias Sneakers23.Inventory.Product

  test "a product can be inserted correctly" do
    params = Test.Factory.ProductFactory.params()

    assert {:ok, product = %Product{}} =
             %Product{}
             |> Product.changeset(params)
             |> Repo.insert()

    Enum.each(params, fn {key, val} ->
      assert Map.fetch!(product, key) == val
    end)
  end
end
