defmodule Sneakers23.Checkout do
  alias __MODULE__.{ShoppingCart}

  defdelegate add_item_to_cart(cart, item), to: ShoppingCart, as: :add_item

  defdelegate cart_item_ids(cart), to: ShoppingCart, as: :item_ids

  defdelegate export_cart(cart), to: ShoppingCart, as: :serialize

  defdelegate remove_item_from_cart(cart, item), to: ShoppingCart, as: :remove_item

  def purchase_cart(cart, opts \\ []) do
    Sneakers23.Repo.transaction(fn ->
      Enum.each(cart_item_ids(cart), fn id ->
        case Sneakers23.Checkout.SingleItem.sell_item(id, opts) do
          :ok ->
            :ok

          _ ->
            Sneakers23.Repo.rollback(:purchase_failed)
        end
      end)

      :purchase_complete
    end)
  end

  def restore_cart(nil), do: ShoppingCart.new()

  def restore_cart(serialized) do
    case ShoppingCart.deserialize(serialized) do
      {:ok, cart} -> cart
      {:error, _} -> restore_cart(nil)
    end
  end

  @cart_id_length 64
  def generate_cart_id() do
    :crypto.strong_rand_bytes(@cart_id_length)
    |> Base.encode64()
    |> binary_part(0, @cart_id_length)
  end
end
