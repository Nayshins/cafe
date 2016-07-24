defmodule Cafe do
  use ExActor.GenServer

  defstart start_link(cache_name), genserver_ops: [name: cache_name] do
    :ets.new(cache_name, [:named_table, :set, :public])
    initial_state(cache_name)
  end

  def start_link(cache_name) do
    GenServer.start_link(__MODULE__, [{:cache_name, cache_name}])
  end

  def init(args) do
    [{:cache_name, cache_name}] = args
    :ets.new(cache_name, [:named_table, :set, {:read_concurrency, true}])
    {:ok, %{cache_name: cache_name}}
  end

  def get(cache_name, key) do
    case :ets.lookup(cache_name, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  def put(cache_name, key, value) do
    :ets.insert(cache_name, {key, value})
  end
end
