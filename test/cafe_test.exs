defmodule CafeTest do
  use ExUnit.Case

  test "inserts a key and value into the ets table" do
    {:ok, pid} = Cafe.start_link(:test_cache)

    GenServer.call(pid, {:put, "Foo", "Bar"})

    assert Cafe.get(:test_cache, "Foo") == {:ok, "Bar"}
  end
end
