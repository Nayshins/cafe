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

      assert {:ok, "Baz"} = GenServer.call(pid, {:get, "Foo"})
    end
  end

  describe "get/1" do
    test "does not return a value if it is past expiry time", %{pid: pid} do
      GenServer.call(pid, {:put, "Foo", "Bar", 0})

      assert {:error, :key_expired} = GenServer.call(pid, {:get, "Foo"})
    end

    test "retrieves a value from the ets table", %{pid: pid} do
      GenServer.call(pid, {:put, "Foo", "Bar"})

      assert {:ok, "Bar"} = GenServer.call(pid, {:get, "Foo"})
    end

    test "returns :no_key error when the key does exist", %{pid: pid} do
      assert {:error, :no_key} = GenServer.call(pid, {:get, "Foo"})
    end
  end

  test "deletes a key", %{pid: pid} do
    GenServer.call(pid, {:put, "Foo", "Baz"})
    assert :ok = GenServer.call(pid, {:delete, "Foo"})

    assert {:error, :no_key} = GenServer.call(pid, {:get, "Foo"})
  end
end
