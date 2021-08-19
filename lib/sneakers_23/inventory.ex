#---
# Excerpted from "Real-Time Phoenix",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/sbsockets for more book information.
#---
defmodule Sneakers23.Inventory do
  alias __MODULE__.{CompleteProduct, DatabaseLoader, Server, Store}

  def child_spec(opts) do
    loader = Keyword.get(opts, :loader, DatabaseLoader)
    name = Keyword.get(opts, :name, __MODULE__)

    %{
      id: Server,
      start: {Server, :start_link, [[loader_mod: loader, name: name]]}
    }
  end

  def get_complete_products(opts \\ []) do
    pid = Keyword.get(opts, :pid, __MODULE__)
    {:ok, inventory} = Server.get_inventory(pid)
    complete_products = CompleteProduct.get_complete_products(inventory)
    {:ok, complete_products}
  end

  def mark_product_released!(id), do: mark_product_released!(id, [])

  def mark_product_released!(product_id, opts) do
    pid = Keyword.get(opts, :pid, __MODULE__)

    %{id: id} = Store.mark_product_released!(product_id)
    {:ok, _inventory} = Server.mark_product_released!(pid, id)

    :ok
  end

  def item_sold!(id), do: item_sold!(id, [])

  def item_sold!(item_id, opts) do
    pid = Keyword.get(opts, :pid, __MODULE__)

    avail = Store.fetch_availability_for_item(item_id)
    {:ok, _old_inv, _inv} = Server.set_item_availability(pid, avail)

    :ok
  end
end
