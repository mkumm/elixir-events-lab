defmodule Vend.Events do
  @moduledoc """
  Everything that can happen to a vending machine.

  Each event is a plain struct describing a fact in the past tense.
  Amounts are in cents. Every event has an `at` timestamp, which the
  event store saves in its own column.
  """

  defmodule CashInserted do
    @moduledoc "A customer put money in. It becomes their credit."
    defstruct [:amount, :at]
  end

  defmodule ItemSold do
    @moduledoc "An item dropped. The price was taken from the customer's credit."
    defstruct [:slot, :price, :at]
  end

  defmodule ChangeReturned do
    @moduledoc "The machine paid out the customer's remaining credit."
    defstruct [:amount, :at]
  end

  defmodule ItemRestocked do
    @moduledoc "The owner loaded items into a slot, paying `unit_cost` for each."
    defstruct [:slot, :quantity, :unit_cost, :at]
  end

  defmodule CashCollected do
    @moduledoc "The owner emptied money from the cash box."
    defstruct [:amount, :at]
  end
end
