defmodule Master do
  use GenServer

  def add_saturated(pid, node_num) do
    GenServer.cast(pid, {:add_saturated, node_num})
  end

  def get_saturated(pid) do
    GenServer.call(pid, :get_saturated, :infinity)
  end

  def get_neighbour(pid, node_id, topology, n) do
    GenServer.call(pid, {:get_neighbour, node_id, topology, n}, :infinity)
  end

  def random(topo, numNodes, nodeId, messages) do
    nodeList = Topology.checkRnd(topo, numNodes, nodeId)
    nodeList = Enum.filter(nodeList, fn el -> !Enum.member?(messages, el) end)
    nodeLen = Kernel.length(nodeList)

    if nodeLen == 0 do
      :noneighbour
    else
      randomNeighbour = :rand.uniform(nodeLen)
      Enum.at(nodeList, randomNeighbour - 1)
    end
  end

  # Server APIs

  def init(messages) do
    {:ok, messages}
  end

  def handle_call(:get_saturated, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_neighbour, node_id, topology, n}, _from, state) do
    neighbour_id = random(topology, n, node_id, state)
    {:reply, neighbour_id, state}
  end

  def handle_cast({:add_saturated, node_num}, state) do
    {:noreply, [node_num | state]}
  end

end
