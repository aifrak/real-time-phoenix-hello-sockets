defmodule HelloSocketsWeb.DedupeChannelTest do
  use HelloSocketsWeb.ChannelCase

  alias HelloSocketsWeb.UserSocket

  test "a buffer is maintained as numbers are broadcasted" do
    connect()
    |> broadcast_number(1)
    |> validate_buffer_contents([1])
    |> broadcast_number(1)
    |> validate_buffer_contents([1, 1])
    |> broadcast_number(2)
    |> validate_buffer_contents([2, 1, 1])

    refute_push _, _
  end

  test "the buffer is drained 1 second after a number is first added" do
    connect()
    |> broadcast_number(1)
    |> broadcast_number(1)
    |> broadcast_number(2)

    Process.sleep(1050)

    assert_push "number", %{value: 1}, 0
    refute_push "number", %{value: 1}, 0
    assert_push "number", %{value: 2}, 0
  end

  test "the buffer drains with unique values in the correct order" do
    connect()
    |> broadcast_number(1)
    |> broadcast_number(2)
    |> broadcast_number(3)
    |> broadcast_number(2)

    Process.sleep(1050)

    assert {:messages,
            [
              %Phoenix.Socket.Message{
                event: "number",
                payload: %{value: 1}
              },
              %Phoenix.Socket.Message{
                event: "number",
                payload: %{value: 2}
              },
              %Phoenix.Socket.Message{
                event: "number",
                payload: %{value: 3}
              }
            ]} = Process.info(self(), :messages)
  end

  defp broadcast_number(socket, number) do
    assert broadcast_from!(socket, "number", %{number: number}) == :ok

    socket
  end

  defp validate_buffer_contents(socket, expected_contents) do
    assert :sys.get_state(socket.channel_pid).assigns == %{
             awaiting_buffer?: true,
             buffer: expected_contents
           }

    socket
  end

  defp connect() do
    assert {:ok, _, socket} =
             socket(UserSocket, nil, %{})
             |> subscribe_and_join("dupe", %{})

    socket
  end
end
