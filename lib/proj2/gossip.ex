defmodule Gossip do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def send_message(pid, {message, number, topology, n}) do
    GenServer.cast(pid, {:send_message, message, number, topology, n})
  end

  # SERVER APIs

  def init(messages) do
    {:ok, messages}
  end

  def handle_cast({:send_message, message, node_id, topology, n}, messages) do
    if messages == 9 do
      Master.add_saturated(:global.whereis_name(:master), node_id)
    end

    Task.async(fn -> keep_spreading(message, node_id, topology, n) end)
    messages = messages + 1
    {:noreply, messages}
  end

  # Implementations

  def keep_spreading(message, node_id, topology, n) do
    :timer.sleep(1)

    neighbour_id =
      Master.get_neighbour(:global.whereis_name(:master), node_id, topology, n)

    name = String.to_atom("node#{neighbour_id}")
    Gossip.send_message(:global.whereis_name(name), {message, neighbour_id, topology, n})
    keep_spreading(message, node_id, topology, n)
  end

  def init_nodes(num) do
    Enum.each(1..num, fn i -> create_node(i) end)
  end

  def create_node(n) do
    name = String.to_atom("node#{n}")
    {:ok, pid} = GenServer.start_link(Gossip, 1, name: name)
    :global.register_name(name, pid)
  end
end
