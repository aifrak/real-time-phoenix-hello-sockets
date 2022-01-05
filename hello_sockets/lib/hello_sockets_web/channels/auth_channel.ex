defmodule HelloSocketsWeb.AuthChannel do
  alias HelloSockets.Pipeline.Timing

  use Phoenix.Channel

  require Logger

  intercept ["push_timed"]

  def join("user:" <> req_user_id, _payload, socket = %{assigns: %{user_id: user_id}}) do
    if req_user_id == to_string(user_id) do
      {:ok, socket}
    else
      Logger.error("#{__MODULE__} failed #{req_user_id} != #{user_id}")
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_out("push_timed", %{data: data, at: enqueued_at}, socket) do
    push(socket, "push_timed", data)

    HelloSockets.Statix.histogram(
      "pipeline.push_delivered",
      Timing.unix_ms_now() - enqueued_at
    )

    {:noreply, socket}
  end
end
