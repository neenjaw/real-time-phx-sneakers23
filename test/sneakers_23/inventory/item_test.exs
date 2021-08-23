defmodule Sneakers23.Inventory.ItemTest do
  use Sneakers23.DataCase, async: true
  alias Sneakers23.Inventory.Item

  test "an item can be inserted correctly" do
    params = Test.Factory.ItemFactory.params()

    assert {:ok, item = %Item{}} =
             %Item{}
             |> Item.changeset(params)
             |> Repo.insert()

    Enum.each(params, fn {key, val} ->
      assert Map.fetch!(item, key) == val
    end)
  end
end
