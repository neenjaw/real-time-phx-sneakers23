defmodule Sneakers23Web.ShoppingCartChannelTest do
  # async false due to global Inventory process
  use Sneakers23Web.ChannelCase, async: false

  alias Sneakers23.Checkout
  alias Sneakers23Web.ProductSocket

  defp cart_id(), do: Checkout.generate_cart_id()

  defp test_cart(0), do: Checkout.restore_cart(nil)

  defp test_cart(item_count) do
    Enum.reduce(1..item_count, Checkout.restore_cart(nil), fn id, cart ->
      {:ok, cart} = Checkout.add_item_to_cart(cart, id)
      cart
    end)
  end

  defp join_with_cart(cart) do
    {:ok, serialized} = Checkout.export_cart(cart)

    {:ok, _, socket} =
      socket(ProductSocket, nil, %{})
      |> subscribe_and_join("cart:#{cart_id()}", %{"serialized" => serialized})

    socket
  end

  describe "join/3" do
    test "a nil parameter will initialize a new cart" do
      assert {:ok, _, socket} =
               socket(ProductSocket, nil, %{})
               |> subscribe_and_join("cart:#{cart_id()}", %{})

      assert socket.assigns.cart == Checkout.restore_cart(nil)
    end

    test "a `serialized` parameter will restore the provided cart" do
      cart = test_cart(1)

      assert {:ok, serialized} = Checkout.export_cart(cart)

      assert {:ok, _, socket} =
               socket(ProductSocket, nil, %{})
               |> subscribe_and_join("cart:#{cart_id()}", %{"serialized" => serialized})

      assert socket.assigns.cart == cart
    end

    test "the cart is pushed to the client on join" do
      cart = test_cart(1)

      join_with_cart(cart)
      assert_push "cart", %{serialized: pushed_serialized, items: []}, 0

      assert Checkout.restore_cart(pushed_serialized) == cart
    end

    # test "items in the cart are subscribed to for PubSub item_out" do
    #   cart = test_cart(3)
    #   join_with_cart(cart)

    #   # Clear out the push that happens post-join by asserting on it
    #   assert_push "cart", _

    #   ids = Checkout.cart_item_ids(cart)
    #   assert length(ids) == 3

    #   Enum.each(ids, fn id ->
    #     Sneakers23Web.notify_local_item_stock_change(%{id: id, available_count: 0})
    #     assert_push "cart", _
    #   end)

    #   Enum.each([10, 11, 12], fn id ->
    #     Sneakers23Web.notify_local_item_stock_change(%{id: id, available_count: 0})
    #     refute_push "cart", _
    #   end)
    # end
  end

  describe "handle_in add_item" do
    test "the item is added to the assigned cart" do
      cart = test_cart(0)
      socket = join_with_cart(cart)
      assert_push "cart", %{serialized: _, items: []}

      ref = push(socket, "add_item", %{"item_id" => "1"})
      assert_reply ref, :ok, %{serialized: serialized_cart, items: _}
      assert Checkout.restore_cart(serialized_cart) |> Checkout.cart_item_ids() == [1]

      ref = push(socket, "add_item", %{"item_id" => "2"})
      assert_reply ref, :ok, %{serialized: serialized_cart, items: _}
      assert Checkout.restore_cart(serialized_cart) |> Checkout.cart_item_ids() == [2, 1]
    end

    test "a duplicate item is an error" do
      cart = test_cart(1)
      socket = join_with_cart(cart)
      assert_push "cart", %{serialized: _, items: []}

      ref = push(socket, "add_item", %{"item_id" => "1"})
      assert_reply ref, :error, %{error: "duplicate_item"}
    end

    test "cart_updated is broadcast" do
      cart = test_cart(0)
      socket = join_with_cart(cart)
      assert_push "cart", %{serialized: _, items: []}

      push(socket, "add_item", %{"item_id" => "1"})

      assert_broadcast "cart_updated", %{"serialized" => serialized_cart}
      assert Checkout.restore_cart(serialized_cart) |> Checkout.cart_item_ids() == [1]
    end

    #   test "a PubSub subscription for the item is added" do
    #     cart = test_cart(0)
    #     socket = join_with_cart(cart)
    #     assert_push "cart", %{serialized: _, items: []}

    #     push(socket, "add_item", %{"item_id" => "1"})
    #     wait_until_messages_processed(socket)

    #     Sneakers23Web.notify_local_item_stock_change(%{id: 1, available_count: 0})
    #     assert_push "cart", _

    #     Sneakers23Web.notify_local_item_stock_change(%{id: 2, available_count: 0})
    #     refute_push "cart", _
    #   end
  end

  describe "handle_in remove_item" do
    test "the item is removed from the assigned cart" do
      cart = test_cart(2)
      socket = join_with_cart(cart)
      assert_push "cart", %{serialized: _, items: []}

      ref = push(socket, "remove_item", %{"item_id" => "1"})
      assert_reply ref, :ok, %{serialized: serialized_cart, items: _}
      assert Checkout.restore_cart(serialized_cart) |> Checkout.cart_item_ids() == [2]

      ref = push(socket, "remove_item", %{"item_id" => "2"})
      assert_reply ref, :ok, %{serialized: serialized_cart, items: _}
      assert Checkout.restore_cart(serialized_cart) |> Checkout.cart_item_ids() == []
    end

    test "an item not in the cart is an error" do
      cart = test_cart(0)
      socket = join_with_cart(cart)
      assert_push "cart", %{serialized: _, items: []}

      ref = push(socket, "remove_item", %{"item_id" => "1"})
      assert_reply ref, :error, %{error: "not_found"}
    end

    test "cart_updated is broadcasted" do
      cart = test_cart(2)
      socket = join_with_cart(cart)
      assert_push "cart", %{serialized: _, items: []}

      push(socket, "remove_item", %{"item_id" => "1"})

      assert_broadcast "cart_updated", %{"serialized" => serialized_cart}
      assert Checkout.restore_cart(serialized_cart) |> Checkout.cart_item_ids() == [2]
    end

    # test "the PubSub subscription for the item is removed" do
    #   cart = test_cart(1)
    #   socket = join_with_cart(cart)
    #   assert_push "cart", %{serialized: _, items: []}

    #   Sneakers23Web.notify_local_item_stock_change(%{id: 1, available_count: 0})
    #   assert_push "cart", _

    #   push(socket, "remove_item", %{"item_id" => "1"})
    #   wait_until_messages_processed(socket)

    #   Sneakers23Web.notify_local_item_stock_change(%{id: 1, available_count: 0})
    #   refute_push "cart", _
    # end
  end

  describe "handle_out cart_updated" do
    test "the assigned cart is updated" do
      cart = test_cart(1)
      other_cart = test_cart(3)
      {:ok, serialized} = Checkout.export_cart(other_cart)
      socket = join_with_cart(cart)

      broadcast_from(socket, "cart_updated", %{
        "serialized" => serialized,
        "added" => [],
        "removed" => []
      })

      assert :sys.get_state(socket.channel_pid).assigns.cart == other_cart
    end

    test "the cart is pushed to the client" do
      cart = test_cart(1)
      other_cart = test_cart(3)
      {:ok, serialized} = Checkout.export_cart(other_cart)

      socket = join_with_cart(cart)
      assert_push "cart", _

      broadcast_from(socket, "cart_updated", %{
        "serialized" => serialized,
        "added" => [],
        "removed" => []
      })

      assert_push "cart", %{serialized: serialized_push, items: []}
      assert Checkout.restore_cart(serialized_push) == other_cart
    end

    # test "added items are subscribed to" do
    #   cart = test_cart(1)
    #   other_cart = test_cart(3)
    #   {:ok, serialized} = Checkout.export_cart(other_cart)
    #   socket = join_with_cart(cart)
    #   assert_push "cart", _

    #   broadcast_from(socket, "cart_updated", %{
    #     "serialized" => serialized,
    #     "added" => [10],
    #     "removed" => []
    #   })

    #   assert_push "cart", _

    #   wait_until_messages_processed(socket)

    #   Sneakers23Web.notify_local_item_stock_change(%{id: 10, available_count: 0})
    #   assert_push "cart", _
    # end

    #   test "removed items are unsubscribed to" do
    #     cart = test_cart(1)
    #     other_cart = test_cart(3)
    #     {:ok, serialized} = Checkout.export_cart(other_cart)
    #     socket = join_with_cart(cart)
    #     assert_push "cart", _

    #     broadcast_from(socket, "cart_updated", %{
    #       "serialized" => serialized,
    #       "added" => [],
    #       "removed" => [1]
    #     })

    #     assert_push "cart", _

    #     wait_until_messages_processed(socket)

    #     Sneakers23Web.notify_local_item_stock_change(%{id: 1, available_count: 0})
    #     refute_push "cart", _
    #   end
  end

  # describe "handle_info {:item_out, id}" do
  #   test "the cart is pushed to the client" do
  #     cart = test_cart(1)
  #     socket = join_with_cart(cart)
  #     assert_push "cart", _

  #     send(socket.channel_pid, {:item_out, 1})
  #     wait_until_messages_processed(socket)
  #     assert_push "cart", _
  #   end
  # end

  # defp wait_until_messages_processed(socket = %{channel_pid: pid}) do
  #   if Process.info(pid, :message_queue_len) == {:message_queue_len, 0} do
  #     # Ensures that no message is actively processing
  #     :sys.get_state(pid)
  #     :ok
  #   else
  #     Process.sleep(10)
  #     wait_until_messages_processed(socket)
  #   end
  # end
end
