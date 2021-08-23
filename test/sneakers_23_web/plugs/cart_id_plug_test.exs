defmodule Sneakers23Web.CartIdPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Sneakers23Web.CartIdPlug

  test "a new cart id is assigned if one isn't present" do
    assert conn(:get, "/")
           |> init_test_session(%{})
           |> CartIdPlug.call([])
           |> get_session()
           |> Map.fetch!("cart_id")
           |> byte_size() == 64
  end

  test "the same cart id is assigned if one was present" do
    assert conn(:get, "/")
           |> init_test_session(%{"cart_id" => "test"})
           |> CartIdPlug.call([])
           |> get_session()
           |> Map.fetch!("cart_id") == "test"
  end
end
