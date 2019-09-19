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
    check_convergance(:gossip, n, start_time)
  end

  def find_network([n, topology, _algorithm]) do
    n = String.to_integer(n)
  end
end
