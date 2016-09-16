defmodule Cafe do
  use GenServer

  def start_link(cache_name) do
    GenServer.start_link(__MODULE__, cache_name)
  end

  def init(cache_name) do
    :ets.new(cache_name, [:named_table, :set, :protected])
    {:ok, cache_name}
  end

  def get(cache_name, key) do
    case :ets.lookup(cache_name, key) do
      [{^key, value}] -> {:ok, value}
      [] -> {:error, :no_key}
    end
  end

  def handle_call({:put, key, value}, _from, cache_name) do
    insert(cache_name, key, value)
    {:reply, :ok, cache_name}
  end

  def handle_call({:delete, key}, _from, cache_name) do
    :ets.delete(cache_name, key)
    {:reply, :ok, cache_name}
  end

  def insert(cache_name, key, value) do
    :ets.insert(cache_name, {key, value})
  end
end
