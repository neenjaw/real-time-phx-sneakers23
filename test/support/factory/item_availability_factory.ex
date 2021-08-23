defmodule Test.Factory.ItemAvailabilityFactory do
  alias Sneakers23.Repo
  alias Sneakers23.Inventory.ItemAvailability
  alias Test.Factory.ItemFactory

  def params(overrides \\ %{}) do
    item_id =
      Map.get_lazy(overrides, :item_id, fn ->
        ItemFactory.create!().id
      end)

    %{
      item_id: item_id,
      available_count: 10
    }
    |> Map.merge(overrides)
  end

  def create!(overrides \\ %{}) do
    %ItemAvailability{}
    |> ItemAvailability.changeset(params(overrides))
    |> Repo.insert!()
  end
end
