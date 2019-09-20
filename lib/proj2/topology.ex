defmodule Topology do
	def select_topology(topology, n, node_id) do
    cond do
      topology == "line" ->
        cond do
          node_id == 1 -> [node_id + 1]
          node_id == n -> [node_id - 1]
          true -> [node_id + 1, node_id - 1]
        end

      topology == "full" ->
        Enum.to_list(1..n)

      true ->
        "Select a valid topology"
    end
  end

  def checkRnd(topology, n, node_id) do
    nodeList = select_topology(topology, n, node_id)
    nodeList = Enum.filter(nodeList, fn x -> x != node_id == true end)
    nodeList = Enum.filter(nodeList, fn x -> x != 0 == true end)
    nodeList = Enum.filter(nodeList, fn x -> x <= n == true end)
    nodeList = Enum.uniq(nodeList)
    nodeList
  end
end