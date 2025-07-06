defmodule Nautsladder.OAuthMock do
  @behaviour Assent.Strategy

  @test_user %{"sub" => 0, "username" => "Timothy van Test"}

  @impl Assent.Strategy
  def authorize_url(_config) do
    {:ok, %{url: "/oauth/discord/callback"}}
  end

  @impl Assent.Strategy
  def callback(_config, _params) do
    {:ok, %{user: @test_user}}
  end
end
