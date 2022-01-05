defmodule HelloSockets.Pipeline.ConsumerSupervisor do
  alias HelloSockets.Pipeline.{Producer, Worker}

  use ConsumerSupervisor

  def start_link(opts) do
    ConsumerSupervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    subscribe_to = Keyword.get(opts, :subscribe_to, Producer)
    supervisor_opts = [strategy: :one_for_one, subscribe_to: subscribe_to]

    children = [
      %{id: Worker, start: {Worker, :start_link, []}, restart: :transient}
    ]

    ConsumerSupervisor.init(children, supervisor_opts)
  end
end
