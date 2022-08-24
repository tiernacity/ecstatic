defmodule Ecstatic.Repo.Migrations.CreateCommandProjection do
  use Ecto.Migration

  def change do
    create table(:commands) do
      add :application_id, :string
      add :component_name, :string
      add :name, :string
      add :schema, :map
      add :handler, :map
    end

    create unique_index(:commands, [:application_id, :name])
  end
end