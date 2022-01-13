defmodule HelloSocketsWeb.UserTracker do
  require Logger

  @behaviour Phoenix.Tracker

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(opts) do
    opts =
      opts
      |> Keyword.put(:name, __MODULE__)
      |> Keyword.put(:pubsub_server, HelloSockets.PubSub)

    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)

    {:ok, %{pubsub_server: server}}
  end

  def handle_diff(changes, state) do
    Logger.info(inspect({"tracked changes", changes}))

    {:ok, state}
  end

  def track(%{channel_pid: pid, topic: topic, assigns: %{user_id: user_id}}) do
    metadata = %{
      online_at: DateTime.utc_now(),
      user_id: user_id
    }

    Phoenix.Tracker.track(__MODULE__, pid, topic, user_id, metadata)
  end

  def list(topic \\ "tracked") do
    Phoenix.Tracker.list(__MODULE__, topic)
  end
end
