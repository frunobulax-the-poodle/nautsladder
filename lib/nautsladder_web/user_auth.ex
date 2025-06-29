defmodule NautsladderWeb.UserAuth do
  use NautsladderWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Nautsladder.Accounts

  def log_in_user(conn, user) do
    return = get_session(conn, :user_return_to)
    conn = assign(conn, :current_user, user)

    conn
    |> renew_session()
    |> put_session(:user_id, user.id)
    |> put_session(:live_socket_id, "users_sessions:#{user.id}")
    |> redirect(to: return || signed_in_path(conn))
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      NautsladderWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> redirect(to: ~p"/")
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Authenticates the user by looking into the session
  """
  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user!(user_id)
    assign(conn, :current_user, user)
  end

  def on_mount(:current_user, _params, session, socket) do
    case session do
      %{"user_id" => user_id} ->
        {:cont,
         Phoenix.Component.assign_new(socket, :current_user, fn -> Accounts.get_user!(user_id) end)}

      %{} ->
        {:cont, Phoenix.Component.assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    case session do
      %{"user_id" => user_id} ->
        new_socket =
          Phoenix.Component.assign_new(socket, :current_user, fn ->
            Accounts.get_user!(user_id)
          end)

        %Accounts.User{} = new_socket.assigns.current_user
        {:cont, new_socket}

      %{} ->
        {:halt, require_login(socket)}
    end
  rescue
    Ecto.NoResultsError -> {:halt, require_login(socket)}
  end

  defp require_login(socket) do
    Phoenix.LiveView.put_flash(socket, :error, "Please sign in")
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
