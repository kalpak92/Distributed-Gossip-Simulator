defmodule Starter do
  def start(args) do
    start_time = System.system_time(:millisecond)

    :global.register_name(:main_process, self())

    n = find_network(args)
    #IO.puts(n)
    if n == 0 || (Enum.at(args,2) != "gossip" && Enum.at(args,2) != "push-sum") do
      IO.puts "Please provide valid arguments"
      IO.puts "Valid Topologies: line, full, rand2D, 3Dtorus, honeycomb and randhoneycomb"
      IO.puts "Valid Algorithms: gossip and push-sum"
    else
      starting_node = :rand.uniform(n)  
      case args do
        [_, topology, "gossip"] ->
          run_gossip({n, starting_node, topology}, start_time)

        [_, topology, "push-sum"] ->
          run_pushsum({n, starting_node, topology}, start_time)
        _ ->
          "Algorithm not valid."
      end
    end
  end

  def run_gossip({n, starting_node, topology}, start_time) do
    Gossip.init_nodes(n)
    {:ok, pid} = GenServer.start_link(Master, [], name: :master)
    :global.register_name(:master, pid)
    :global.sync()

    name = String.to_atom("node#{starting_node}")

    Gossip.send_message(:global.whereis_name(name),{"Gossip", starting_node, topology, n})
    Gossip.check_convergence(n, start_time)
  end


  def run_pushsum({n, starting_node, topology}, start_time) do
    PushSum.initializeNodes(n)
    {:ok, pid} = GenServer.start_link(Master, [], name: :master)
    :global.register_name(:master, pid)
    :global.sync

    name = String.to_atom("node#{starting_node}")

    PushSum.send_message(:global.whereis_name(name),{"Push-Sum",starting_node,topology,n,0,0})

    PushSum.check_convergence(n, start_time, topology) # figure out this part
  end


  def check_convergence(:gossip, n, start_time) do
    converged =
      Enum.all?(1..n, fn node_num ->
        name = String.to_atom("node#{node_num}")
        messages = :sys.get_state(:global.whereis_name(name))
        messages > 1
      end)

      if converged do
        IO.puts("Converged in #{(System.system_time(:millisecond) - start_time) / 1000} seconds")
        Process.exit(self(), :kill)
      end

      check_convergence(:gossip, n, start_time)
  end

  def find_network([n, topology, _algorithm]) do
    n = String.to_integer(n)
    cond do
    	topology == "rand2D" ->
        sqrt = :math.sqrt(n) |> Float.floor() |> round
        n = :math.pow(sqrt, 2) |> round
        #IO.puts(n)
    		Topology.initialize_ets_tables(n)
    		n
      topology == "3Dtorus" ->
        root = :math.pow(n, 0.33) |> Float.floor() |> round
        n = :math.pow(root,3) |> round
        Topology.initialize_torus_table(n)
        n
      topology == "honeycomb" ->
        nearest_root = :math.sqrt(n) |> Float.floor() |> round
        val = rem(nearest_root,4)
        add = 4-val
        n = :math.pow(nearest_root+add,2) |> round
        Topology.initialize_honeycomb_table(n)
        n
      topology == "randhoneycomb" ->
        nearest_root = :math.sqrt(n) |> Float.floor() |> round
        val = rem(nearest_root,4)
        add = 4-val
        n = :math.pow(nearest_root+add,2) |> round
        Topology.initialize_honeycomb_random_table(n)
        n
    	topology == "line" || topology == "full" ->
    		n
      true ->
        0
    end
  end
end
