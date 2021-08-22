defmodule Sneakers23.Checkout.ShoppingCartTest do
  use ExUnit.Case, async: true

  alias Sneakers23.Checkout.ShoppingCart

  describe "new/0" do
    test "an empty cart is returned" do
      assert ShoppingCart.new() == %ShoppingCart{items: []}
    end
  end

  describe "add_item/2" do
    test "items are added to the cart" do
      cart = ShoppingCart.new()
      assert {:ok, cart = %{items: [1]}} = ShoppingCart.add_item(cart, 1)
      assert {:ok, %{items: [2, 1]}} = ShoppingCart.add_item(cart, 2)
    end

    test "duplicate items return an error" do
      cart = ShoppingCart.new()
      assert {:ok, cart} = ShoppingCart.add_item(cart, 1)
      assert ShoppingCart.add_item(cart, 1) == {:error, :duplicate_item}
    end
  end

  describe "remove_item/2" do
    test "items are removed to the cart" do
      cart = ShoppingCart.new()
      assert {:ok, cart = %{items: [1]}} = ShoppingCart.add_item(cart, 1)
      assert {:ok, cart = %{items: [2, 1]}} = ShoppingCart.add_item(cart, 2)
      assert {:ok, cart = %{items: [2]}} = ShoppingCart.remove_item(cart, 1)
      assert {:ok, cart = %{items: []}} = ShoppingCart.remove_item(cart, 2)
    end

    test "non-existent items are an error" do
      cart = ShoppingCart.new()
      assert ShoppingCart.remove_item(cart, 1) == {:error, :not_found}
    end
  end

  describe "serialization" do
    test "a signed payload is produced that can be deserialized" do
      cart = ShoppingCart.new()
      assert {:ok, cart = %{items: [1]}} = ShoppingCart.add_item(cart, 1)
      assert {:ok, cart = %{items: [2, 1]}} = ShoppingCart.add_item(cart, 2)

      assert {:ok, serialized} = ShoppingCart.serialize(cart)
      assert ShoppingCart.deserialize(serialized) == {:ok, cart}
    end

    test "invalid payloads can't be deserialized" do
      assert ShoppingCart.deserialize("nope") == {:error, :invalid}
    end
  end
end
