defmodule NautsladderWeb.UserSessionController do
  use NautsladderWeb, :controller
  require Logger

  alias Nautsladder.Accounts
  alias NautsladderWeb.UserAuth

  alias Nautsladder.Accounts
  alias NautsladderWeb.UserAuth

  defp config() do
    Application.get_env(:assent, :discord)
    |> Keyword.put(:redirect_uri, NautsladderWeb.Endpoint.url() <> "/oauth/discord/callback")
  end

  defp oauth_provider(), do: Application.get_env(:nautsladder, :oauth_provider)

  def request(conn, _params) do
    config()
    |> oauth_provider().authorize_url()
    |> case do
      {:ok, %{url: url, session_params: params}} ->
        put_session(conn, :session_params, params)
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, err} ->
        Logger.error("Failed authentication request #{inspect(err)}")
        send_resp(conn, 500, "Failed Authentication")
    end
  end

  def callback(conn, params) do
    session_params = get_session(conn, :session_params)

    res =
      config()
      |> Keyword.put(:session_params, session_params)
      |> oauth_provider().callback(params)

    with {:ok, %{user: user}} <- res,
         %{"preferred_username" => username, "picture" => avatar_url, "sub" => discord_id} = user,
         {:ok, user} <-
           Accounts.register_update_user(%{
             discord_id: String.to_integer(discord_id),
             username: username,
             avatar_url: avatar_url
           }) do
      UserAuth.log_in_user(conn, user)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("failed user insert #{inspect(changeset.errors)}")

        conn
        |> put_flash(
          :error,
          "We were unable to fetch the necessary information from your Discord account"
        )
        |> redirect(to: "/")

      {:error, reason} ->
        Logger.error("failed discord exchange #{inspect(reason)}")

        conn
        |> put_flash(:error, "We were unable to sign you in. Please try again later")
        |> redirect(to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
