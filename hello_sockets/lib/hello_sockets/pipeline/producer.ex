defmodule HelloSockets.Pipeline.Producer do
  alias HelloSockets.Pipeline.Timing

  use GenStage

  def start_link(opts) do
    {[name: name], opts} = Keyword.split(opts, [:name])
    GenStage.start_link(__MODULE__, opts, name: name)
  end

  def init(_opts) do
    {:producer, :unused, buffer_size: 10_000}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  def push(item = %{}) do
    GenStage.cast(__MODULE__, {:notify, item})
  end

  def push_timed(item = %{}) do
    GenStage.cast(__MODULE__, {:notify_timed, item, Timing.unix_ms_now()})
  end

  def handle_cast({:notify_timed, item, unix_ms}, state) do
    {:noreply, [%{item: item, enqueued_at: unix_ms}], state}
  end

  def handle_cast({:notify, item}, state) do
    {:noreply, [%{item: item}], state}
  end
end
