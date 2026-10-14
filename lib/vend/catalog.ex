defmodule Vend.Catalog do
  @moduledoc """
  The six slots in the machine. Prices are in cents.

  Prices are fixed configuration. What the owner *pays* for each item
  is not here: that arrives with each restock, as an event.
  """

  @items %{
    "A1" => %{name: "Cola", price: 150},
    "A2" => %{name: "Water", price: 125},
    "A3" => %{name: "Chips", price: 175},
    "B1" => %{name: "Candy bar", price: 150},
    "B2" => %{name: "Gum", price: 100},
    "B3" => %{name: "Trail mix", price: 225}
  }

  def slots, do: Map.keys(@items) |> Enum.sort()
  def fetch(slot), do: Map.fetch(@items, slot)
  def price(slot), do: @items |> Map.fetch!(slot) |> Map.fetch!(:price)
  def name(slot), do: @items |> Map.fetch!(slot) |> Map.fetch!(:name)
end
