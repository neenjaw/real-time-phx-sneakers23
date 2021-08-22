defmodule Sneakers23.Checkout.ShoppingCart do
  defstruct items: []

  alias __MODULE__, as: Cart

  def new(), do: %Cart{}

  def add_item(cart = %Cart{items: items}, id) when is_integer(id) do
    if id in items do
      {:error, :duplicate_item}
    else
      {:ok, %Cart{cart | items: [id | items]}}
    end
  end

  def remove_item(cart = %Cart{items: items}, id) when is_integer(id) do
    if id in items do
      {:ok, %Cart{cart | items: List.delete(items, id)}}
    else
      {:error, :not_found}
    end
  end

  def item_ids(%Cart{items: items}), do: items

  @base Sneakers23Web.Endpoint
  @salt "shopping cart serialization"
  @max_age 86400 * 7

  def serialize(cart = %Cart{}) do
    {:ok, Phoenix.Token.sign(@base, @salt, cart, max_age: @max_age)}
  end

  def deserialize(serialized) do
    case Phoenix.Token.verify(@base, @salt, serialized, max_age: @max_age) do
      {:ok, data} ->
        items = Map.get(data, :items, [])
        {:ok, %Cart{items: items}}

      e = {:error, _reason} ->
        e
    end
  end
end
