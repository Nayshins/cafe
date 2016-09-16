defmodule CafeTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Cafe.start_link(:test_cache)
    {:ok, pid: pid}
  end

  describe "put/1" do
    test "inserts a key and value into the ets table", %{pid: pid} do
      assert :ok = GenServer.call(pid, {:put, "Foo", "Bar"})
    end

    test "updates a key with a new value", %{pid: pid} do
      GenServer.call(pid, {:put, "Foo", "Bar"})
      GenServer.call(pid, {:put, "Foo", "Baz"})

      assert {:ok, "Baz"} = Cafe.get(:test_cache, "Foo")
    end
  end

  describe "get/1" do
    test "retrieves a value from the ets table", %{pid: pid} do
      GenServer.call(pid, {:put, "Foo", "Bar"})

      assert {:ok, "Bar"} = Cafe.get(:test_cache, "Foo")
    end

    test "returns :no_key error when the key does exist" do
      assert {:error, :no_key} = Cafe.get(:test_cache, "Foo")
    end
  end

  test "deletes a key", %{pid: pid} do
    GenServer.call(pid, {:put, "Foo", "Baz"})
    assert :ok = GenServer.call(pid, {:delete, "Foo"})

    assert {:error, :no_key} = Cafe.get(:test_cache, "Foo")
  end
end
