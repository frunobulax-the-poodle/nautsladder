defmodule Nautsladder.Repo.Migrations.CreateUserAuthTables do
  use Ecto.Migration

  def change do
    create table(:account) do
      add :discord_id, :bigint, null: false
      add :username, :string, null: false
      add :avatar_url, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:account, [:discord_id])
  end
end
