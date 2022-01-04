defmodule HelloSocketsWeb.AuthSocket do
  use Phoenix.Socket

  require Logger

  channel "ping", HelloSocketsWeb.PingChannel
  channel "tracked", HelloSocketsWeb.TrackedChannel
  channel "user:*", HelloSocketsWeb.AuthChannel

  @one_day 86400

  def connect(%{"token" => token}, socket) do
    case verify(socket, token) do
      {:ok, user_id} ->
        socket = assign(socket, :user_id, user_id)
        {:ok, socket}

      {:error, err} ->
        Logger.error("#{__MODULE__} connect error #{inspect(err)}")
        :error
    end
  end

  def connect(_, _socket) do
    Logger.error("#{__MODULE__} connect error missing params")
    :error
  end

  def id(%{assigns: %{user_id: user_id}}),
    do: "auth_socket:#{user_id}"

  defp verify(socket, token) do
    Phoenix.Token.verify(
      socket,
      "salt identifier",
      token,
      max_age: @one_day
    )
  end
end
