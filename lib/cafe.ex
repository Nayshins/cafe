defmodule Cafe do
  use GenServer

  def start_link(cache_name) do
    GenServer.start_link(__MODULE__, cache_name)
  end

  def init(cache_name) do
    :ets.new(cache_name, [:named_table, :set, :protected])
    {:ok, cache_name}
  end

  def handle_call({:get, key}, _from, cache_name) do
    current_time = :os.system_time(:seconds)
    case :ets.lookup(cache_name, key) do
      [{_key, value, expiry}] when expiry > current_time ->
        {:reply, {:ok, value}, cache_name}
      [{_key, value, expiry}] -> evict_record(cache_name, key)
      _ -> {:reply, {:error, :no_key}, cache_name}
    end
  end

  def handle_call({:put, key, value}, _from, cache_name) do
    insert(cache_name, key, value, 1)
    {:reply, :ok, cache_name}
  end

  def handle_call({:put, key, value, ttl}, _from, cache_name) do
    insert(cache_name, key, value, ttl)
    {:reply, :ok, cache_name}
  end

  def handle_call({:delete, key}, _from, cache_name) do
    :ets.delete(cache_name, key)
    {:reply, :ok, cache_name}
  end

  defp insert(cache_name, key, value, ttl) do
    expiry = :os.system_time(:seconds) + ttl
    :ets.insert(cache_name, {key, value, expiry})
  end

  defp evict_record(cache_name, key) do
    :ets.delete(cache_name, key)
    {:reply, {:error, :key_expired}, cache_name}
  end
end
