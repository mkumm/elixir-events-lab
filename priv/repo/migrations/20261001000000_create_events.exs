defmodule Vend.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  # The only table in the app. Rows are appended, never updated or deleted.
  def change do
    create table(:events) do
      add :stream_id, :string, null: false
      add :type, :string, null: false
      add :data, :map, null: false
      add :recorded_at, :utc_datetime_usec, null: false
    end

    create index(:events, [:stream_id, :id])
  end
end
