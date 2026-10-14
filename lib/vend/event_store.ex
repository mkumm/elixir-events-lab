defmodule Vend.EventStore do
  @moduledoc """
  An append-only log of events, stored in SQLite.

  A *stream* is the history of one thing, here one machine, identified
  by a string such as `"lobby"`. Events go in as structs and come back
  out as the same structs, oldest first.
  """

  import Ecto.Query
  alias Vend.{Events, Repo}

  # The `type` column stores the short name; this maps it back to a module.
  @types Map.new(
           [
             Events.CashInserted,
             Events.ItemSold,
             Events.ChangeReturned,
             Events.ItemRestocked,
             Events.CashCollected
           ],
           fn module -> {module |> Module.split() |> List.last(), module} end
         )

  defmodule Row do
    @moduledoc false
    use Ecto.Schema

    schema "events" do
      field :stream_id, :string
      field :type, :string
      field :data, :map
      field :recorded_at, :utc_datetime_usec
    end
  end

  @doc "Appends a list of events to a stream, atomically."
  def append(stream_id, events) when is_list(events) do
    rows = Enum.map(events, &to_row(stream_id, &1))
    {count, _} = Repo.insert_all(Row, rows)
    {:ok, count}
  end

  @doc "Reads every event in a stream, oldest first."
  def read(stream_id) do
    from(r in Row, where: r.stream_id == ^stream_id, order_by: r.id)
    |> Repo.all()
    |> Enum.map(&from_row/1)
  end

  @doc "Lists every stream that has at least one event."
  def streams do
    from(r in Row, distinct: true, select: r.stream_id, order_by: r.stream_id)
    |> Repo.all()
  end

  defp to_row(stream_id, %module{} = event) do
    %{
      stream_id: stream_id,
      type: module |> Module.split() |> List.last(),
      data: event |> Map.from_struct() |> Map.delete(:at),
      recorded_at: event.at || DateTime.utc_now()
    }
  end

  defp from_row(%Row{type: type, data: data, recorded_at: recorded_at}) do
    event = struct(Map.fetch!(@types, type))
    fields = Map.new(data, fn {k, v} -> {String.to_existing_atom(k), v} end)

    event
    |> Map.merge(fields)
    |> Map.put(:at, recorded_at)
  end
end
