defmodule Sneakers23.Inventory.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :brand, :string
    field :color, :string
    field :main_image_url, :string
    field :name, :string
    field :order, :integer
    field :price_usd, :integer
    field :released, :boolean, default: false
    field :sku, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:sku, :order, :brand, :name, :color, :price_usd, :main_image_url, :released])
    |> validate_required([
      :sku,
      :order,
      :brand,
      :name,
      :color,
      :price_usd,
      :main_image_url,
      :released
    ])
  end
end
