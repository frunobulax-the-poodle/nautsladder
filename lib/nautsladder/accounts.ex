defmodule Nautsladder.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Nautsladder.Repo

  alias Nautsladder.Accounts.User

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, username: username)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def register_update_user(user) do
    if registered = Repo.get_by(User, discord_id: user.discord_id) do
      registered
      |> User.update_changeset(user)
      |> Repo.update()
    else
      user
      |> User.registration_changeset()
      |> Repo.insert()
    end
  end
end
