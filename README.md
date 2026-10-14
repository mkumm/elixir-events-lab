# Elixir Events Lab

Starter code for the [Elixir Events lab](https://mkumm.com/labs/elixir-events/): build an event-sourced vending machine in about 45 minutes.

## Setup

Requires Elixir 1.15 or newer. No database server needed; it uses SQLite.

```sh
mix setup      # fetch deps, create the database, seed a week of history
iex -S mix
```

`mix reset` wipes the database and reseeds it.

## What is here

| File | What it does |
| --- | --- |
| `lib/vend/events.ex` | The five event structs |
| `lib/vend/event_store.ex` | `append/2` and `read/1` over a single SQLite table |
| `lib/vend/catalog.ex` | Six slots with names and prices |
| `lib/vend/application.ex` | Supervision tree: Repo, Registry, and (later) your machine |
| `priv/repo/seeds.exs` | One week of history for the `"lobby"` machine |

You write `lib/vend/vending.ex`, `lib/vend/machine.ex`, and `lib/vend/reports.ex` during the lab. The `solution` branch has finished versions.
