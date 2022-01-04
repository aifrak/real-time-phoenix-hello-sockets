defmodule HelloSocketsWeb.DedupeChannel do
  use Phoenix.Channel

  intercept ["number"]

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  def handle_out("number", %{number: number}, socket) do
    buffer = Map.get(socket.assigns, :buffer, [])
    next_buffer = [number | buffer]

    next_socket =
      socket
      |> assign(:buffer, next_buffer)
      |> enqueue_send_buffer()

    {:noreply, next_socket}
  end

  def handle_info(:send_buffer, socket = %{assigns: %{buffer: buffer}}) do
    buffer
    |> Enum.reverse()
    |> Enum.uniq()
    |> Enum.each(&push(socket, "number", %{value: &1}))

    next_socket =
      socket
      |> assign(:buffer, [])
      |> assign(:awaiting_buffer?, false)

    {:noreply, next_socket}
  end

  def broadcast(numbers, times) do
    Enum.each(1..times, fn _ ->
      Enum.each(numbers, fn number ->
        HelloSocketsWeb.Endpoint.broadcast!("dupe", "number", %{
          number: number
        })
      end)
    end)
  end

  defp enqueue_send_buffer(socket = %{assigns: %{awaiting_buffer?: true}}),
    do: socket

  defp enqueue_send_buffer(socket) do
    Process.send_after(self(), :send_buffer, 1_000)
    assign(socket, :awaiting_buffer?, true)
  end
end
