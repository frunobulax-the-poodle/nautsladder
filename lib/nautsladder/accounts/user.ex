defmodule Nautsladder.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Nautsladder.Accounts.User

  schema "users" do
    field :discord_id, :integer
    field :username, :string
    field :avatar_url, :string
    field :authenticated_at, :utc_datetime, virtual: true

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(attrs) do
    %User{}
    |> cast(attrs, [:discord_id, :username, :avatar_url])
    |> validate_required([:discord_id, :username])
  end

  def update_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :avatar_url])
    |> validate_required([:username])
  end
end
