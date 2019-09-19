defmodule Starter do
  def start(args) do
    start_time = System.system_time(:millisecond)

    :global.register_name(:main_process, self())

    n = find_network(args)

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

  def run_gossip({n, starting_node, topology}, start_time) do
    Gossip.init_nodes(n)
    {:ok, pid} = GenServer.start_link(Master, [], name: :master)
    :global.register_name(:master, pid)
    :global.sync()

    name = String.to_atom("node#{starting_node}")

    Gossip.send_message(:global.whereis_name(name),{"Gossip", starting_node, topology, n})
    check_convergence(:gossip, n, start_time)
  end

  @doc """


  def run_pushsum({n, starting_node, topology}, start_time) do
    PushSum.createNodes(n)
    {:ok, pid} = GenServer.start_link(Master, [], name: :master)
    :global.register_name(:master, pid)
    :global.sync

    name = String.to_atom("node#{starting_node}")

    PushSum.send_message(
      :global.whereis_name(name),
      {
        "Push-Sum",
        starting_node,
        topology,
        n,
        0,
        0
      }
    )

    PushSum.check_convergence(n, start_time, topology) # figure out this part
  end

  """

  def check_convergence(:gossip, n, start_time) do
    converged =
      Enum.all?(1..n, fn node_sum ->
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

  def check_convergence(:push_sum, n ,start_time) do
    converged =
      Enum.all?(1..n, fn node_sum ->
        name = String.to_atom("node#{node_num}")
        messages = :sys.get_state(:global.whereis_name(name))
        messages = Enum.at(messages, 2)
        messages > 0
      end)

      if converged do
        IO.puts("Converged in #{(System.system_time(:millisecond) - start_time) / 1000} seconds")
        Process.exit(self(), :kill)
      end

      check_convergence(:push_sum, n, start_time)
  end

  def find_network([n, topology, _algorithm]) do
    n = String.to_integer(n)
  end
end
