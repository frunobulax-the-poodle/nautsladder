defmodule NautsladderWeb.PageController do
  use NautsladderWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
