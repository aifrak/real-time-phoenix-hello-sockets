defmodule HelloSocketsWeb.AuthChannel do
  use Phoenix.Channel

  require Logger

  def join("user:" <> req_user_id, _payload, socket = %{assigns: %{user_id: user_id}}) do
    if req_user_id == to_string(user_id) do
      {:ok, socket}
    else
      Logger.error("#{__MODULE__} failed #{req_user_id} != #{user_id}")
      {:error, %{reason: "unauthorized"}}
    end
  end
end
