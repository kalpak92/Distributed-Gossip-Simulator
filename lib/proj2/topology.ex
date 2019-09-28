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

      topology == "random-2D" ->
        lookup_2d_neighbour(node_id)

      #topology == "torus-3D" ->
       # lookup_3d_torus_neighbour(node_id)

      #topology == "honeycomb" ->
       # lookup_honeycomb_neighbour(node_id)

      #topology == "honeycomb_random" ->
       # lookup_honeycomb_random_neighbour(node_id)

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

  def initialize_ets_tables(n) do
    table = :ets.new(:random_2d, [:named_table])

    map =
      Enum.reduce(1..n, %{}, fn node_id, acc ->
        Map.put(acc, node_id, x: :rand.uniform(100), y: :rand.uniform(100))
      end)

    :ets.insert(table, {"data", map})
    #IO.puts(map)
    #Enum.each(map, fn {node,values} ->
  	#	IO.puts(["Node number: #{node} Position: "| Enum.map(values, fn {a,b} -> "#{a}  #{b}" end)]) end)

    initialize_2d_neighbour_table(n)
  end

  def initialize_2d_neighbour_table(n) do
    table = :ets.new(:random_2d_neighbour, [:named_table])

    map =
      Enum.reduce(1..n, %{}, fn node_id, acc ->
        Map.put(acc, node_id, find_2d_neighbour(node_id))
      end)

    :ets.insert(table, {"data", map})
    #Enum.each(map, fn {node,values} ->
  	#	IO.puts(["Node number: #{node} Nearest Neighbors:"| Enum.map(values, fn x -> " #{x}" end)]) end)
  end

  def find_2d_neighbour(node_id) do
    [{_, map}] = :ets.lookup(:random_2d, "data")
    current_node = map[node_id]

    Enum.filter(1..map_size(map), fn id ->
      dist =
        (:math.pow(map[id][:x] - current_node[:x], 2) +
           :math.pow(map[id][:y] - current_node[:y], 2))
        |> :math.sqrt()

      dist < 10 and id != node_id
    end)
  end

  def lookup_2d_neighbour(node_id) do
    [{_, map}] = :ets.lookup(:random_2d_neighbour, "data")
    map[node_id]
  end

end
