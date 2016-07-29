defmodule Cafe do
  use ExActor.GenServer

  defstart start_link(cache_name), genserver_ops: [name: cache_name] do
    :ets.new(cache_name, [:named_table, :set, :protected])
    initial_state(cache_name)
  end

  def get(cache_name, key) do
    case :ets.lookup(cache_name, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  defcall put(key, value), state: cache_name do
    insert(cache_name, key, value)
    reply(:ok)
  end

  defp insert(cache_name, key, value) do
    :ets.insert(cache_name, {key, value})
  end
end
