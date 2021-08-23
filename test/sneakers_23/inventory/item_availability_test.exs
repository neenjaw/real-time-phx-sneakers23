defmodule Sneakers23.Inventory.ItemAvailabilityTest do
  use Sneakers23.DataCase, async: true
  alias Sneakers23.Inventory.ItemAvailability

  test "an item can be inserted correctly" do
    params = Test.Factory.ItemAvailabilityFactory.params()

    assert {:ok, availability = %ItemAvailability{}} =
             %ItemAvailability{}
             |> ItemAvailability.changeset(params)
             |> Repo.insert()

    Enum.each(params, fn {key, val} ->
      assert Map.fetch!(availability, key) == val
    end)
  end
end
