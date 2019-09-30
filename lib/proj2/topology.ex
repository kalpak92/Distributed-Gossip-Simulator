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

      topology == "torus-3D" ->
        lookup_torus_neighbour(node_id)

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

  def initialize_torus_table(n) do
    table = :ets.new(:torus, [:named_table])
    root=:math.pow(n,0.33) |>round
    square = :math.pow(root,2) |> round

    map =
      Enum.reduce(1..n, %{}, fn node_id, acc ->
        Map.put(acc, node_id, find_torus_neighbour(node_id, n, root, square))
      end)

    :ets.insert(table, {"data", map})
  end

  def find_torus_neighbour(k, n, root, square) do
    # top
    top =
      if Enum.member?(list(n, "top", root, square), k) do
        k + square - root
      else
        k - root
      end

    # bottom
    bottom =
      if Enum.member?(list(n, "bottom", root, square), k) do
        k - square + root
      else
        k + root
      end

    # left
    left =
      if rem(k, root) == 1 do
        k + root - 1
      else
        k - 1
      end

    # right
    right =
      if rem(k, root) == 0 do
        k - root + 1
      else
        k + 1
      end

    front = 
      if Enum.member?(1..square, k) do
        k + n - square
      else
        k - square
      end

    back = 
      if Enum.member?(n-square+1..n,k) do
        k - n + square
      else
        k + square
      end

    [top, bottom, left, right, front, back]
  end

  def lookup_torus_neighbour(node_id) do
    [{_, map}] = :ets.lookup(:torus, "data")
    map[node_id]
  end

  def list(_n, base, root, square) do
    
    list = 
    if base == "top" do
      Enum.to_list(1..root)
    else
      Enum.to_list(square-root+1..square)
    end
    
    begin =
    if base == "top" do
      1
    else
      square-root+1
    end
    
    concatenate(list, begin, 1, square, root)
  end

  defp concatenate(list, _begin, x, _square, root) when x == root do
    list 
  end

  defp concatenate(list, begin, x, square, root) do
    list = list ++ Enum.to_list(begin+(x*square)..begin+(x*square)+root-1)
    concatenate(list,begin,x+1,square,root)
  end
end
