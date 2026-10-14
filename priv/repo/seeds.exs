# Writes one week of history for the "lobby" machine, so the reports in
# the lab have something to chew on. Run by `mix setup` and `mix reset`.
#
# This is an import of past events, so it appends straight to the event
# store with backdated timestamps instead of going through the machine.

alias Vend.{Catalog, EventStore}
alias Vend.Events.{CashInserted, ItemSold, ChangeReturned, ItemRestocked, CashCollected}

if EventStore.streams() != [] do
  IO.puts("Events already exist; skipping seeds. Run `mix reset` to start over.")
else
  :rand.seed(:exsss, {2026, 10, 1})

  start = ~U[2026-10-05 07:00:00.000000Z]

  # What the owner pays per unit. Cola's supplier raises the price midweek.
  cost = fn
    "A1", day when day >= 3 -> 95
    "A1", _ -> 60
    "A2", _ -> 30
    "A3", _ -> 70
    "B1", _ -> 55
    "B2", _ -> 25
    "B3", _ -> 120
  end

  # Customers per hour, 7am to 10pm. Peaks at lunch and late afternoon.
  traffic = %{7 => 1, 8 => 3, 9 => 2, 10 => 2, 11 => 4, 12 => 7, 13 => 5,
              14 => 2, 15 => 4, 16 => 5, 17 => 3, 18 => 2, 19 => 1, 20 => 1, 21 => 1}

  {events, _stock, _cash} =
    Enum.reduce(0..6, {[], %{}, 0}, fn day, {events, stock, cash} ->
      morning = DateTime.add(start, day, :day)

      # Restock anything running low.
      {events, stock} =
        Enum.reduce(Catalog.slots(), {events, stock}, fn slot, {events, stock} ->
          left = Map.get(stock, slot, 0)

          if left < 6 do
            qty = 12 - left
            event = %ItemRestocked{slot: slot, quantity: qty, unit_cost: cost.(slot, day), at: morning}
            {[event | events], Map.put(stock, slot, 12)}
          else
            {events, stock}
          end
        end)

      # Customers.
      {events, stock, cash} =
        Enum.reduce(traffic, {events, stock, cash}, fn {hour, n}, acc ->
          Enum.reduce(1..n, acc, fn _, {events, stock, cash} ->
            slot = Enum.random(Catalog.slots())
            price = Catalog.price(slot)
            at = DateTime.add(morning, (hour - 7) * 3600 + :rand.uniform(3599), :second)

            if stock[slot] > 0 do
              paid = Enum.random([price, 200, 200, 300, 500]) |> max(price)
              sold = [%CashInserted{amount: paid, at: at}, %ItemSold{slot: slot, price: price, at: at}]
              change = if paid > price, do: [%ChangeReturned{amount: paid - price, at: at}], else: []
              {Enum.reverse(sold ++ change) ++ events, Map.update!(stock, slot, &(&1 - 1)), cash + price}
            else
              {events, stock, cash}
            end
          end)
        end)

      # The owner empties the cash box every other evening.
      if rem(day, 2) == 1 do
        at = DateTime.add(morning, 15 * 3600, :second)
        {[%CashCollected{amount: cash, at: at} | events], stock, 0}
      else
        {events, stock, cash}
      end
    end)

  events = Enum.reverse(events)
  {:ok, count} = EventStore.append("lobby", events)
  IO.puts("Seeded #{count} events for the \"lobby\" machine.")
end
