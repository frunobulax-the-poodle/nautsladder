defmodule Nautsladder.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Nautsladder.Accounts` context.
  """

  import Ecto.Query

  alias Nautsladder.Accounts
  alias Nautsladder.Accounts.Scope

  def unique_discord_id, do: System.unique_integer([:positive])

  def valid_user_attributes(attrs \\ %{}) do
    id = unique_discord_id()

    Enum.into(attrs, %{
      discord_id: id,
      username: Integer.to_string(id)
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_update_user()

    user
  end

  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    Nautsladder.Repo.update_all(
      from(t in Accounts.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    Nautsladder.Repo.update_all(
      from(ut in Accounts.UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end
end
