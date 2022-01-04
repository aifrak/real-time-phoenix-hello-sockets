defmodule HelloSocketsWeb.UserSocketTest do
  use HelloSocketsWeb.ChannelCase

  alias HelloSocketsWeb.UserSocket

  describe "connect/3" do
    test "can be connected to without parameters" do
      assert {:ok, %Phoenix.Socket{}} = connect(UserSocket, %{})
    end
  end

  describe "id/1" do
    test "an identifier is not provided" do
      assert {:ok, socket} = connect(UserSocket, %{})
      assert UserSocket.id(socket) == nil
    end
  end
end
