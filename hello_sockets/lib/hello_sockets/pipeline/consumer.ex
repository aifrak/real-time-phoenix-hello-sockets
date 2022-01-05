defmodule HelloSockets.Pipeline.Consumer do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts)
  end

  def init(opts) do
    subscribe_to = Keyword.get(opts, :subscribe_to, HelloSockets.Pipeline.Producer)

    {:consumer, :unused, subscribe_to: subscribe_to}
  end

  def handle_events(items, _from, state) do
    IO.inspect({__MODULE__, length(items), List.first(items), List.last(items)})

    {:noreply, [], state}
  end
end
