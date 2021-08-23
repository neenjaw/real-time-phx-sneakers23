defmodule Sneakers23.Inventory.Server do
  use GenServer

  alias Sneakers23.Inventory.{Inventory, ItemAvailability}

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def get_inventory(pid) do
    GenServer.call(pid, :get_inventory)
  end

  def mark_product_released!(pid, product_id) do
    GenServer.call(pid, {:mark_product_released!, product_id})
  end

  def set_item_availability(pid, item_availability = %ItemAvailability{}) do
    GenServer.call(pid, {:set_item_availability, item_availability})
  end

  # Callbacks

  def init(opts) do
    loader_mod = Keyword.fetch!(opts, :loader_mod)
    {:ok, %{loader_mod: loader_mod}, {:continue, :load}}
  end

  def handle_continue(:load, %{loader_mod: loader_mod}) do
    {:ok, inventory = %Inventory{}} = loader_mod.load()
    {:noreply, inventory}
  end

  def handle_call(:get_inventory, _from, inventory) do
    {:reply, {:ok, inventory}, inventory}
  end

  def handle_call({:mark_product_released!, id}, _from, inventory) do
    new_inventory = Inventory.mark_product_released!(inventory, id)
    {:reply, {:ok, new_inventory}, new_inventory}
  end

  def handle_call({:set_item_availability, availability}, _from, inventory) do
    new_inventory = Inventory.add_availabilities(inventory, [availability])
    {:reply, {:ok, inventory, new_inventory}, new_inventory}
  end

  if Mix.env() == :test do
    def handle_call({:test_set_inventory, inventory}, _from, _old) do
      {:reply, {:ok, inventory}, inventory}
    end
  end
end
