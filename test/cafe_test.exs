defmodule CafeTest do
  use ExUnit.Case

  test "inserts a key and value into the ets table" do
    Cafe.start_link(:test_cache)

    Cafe.put(:test_cache, "Foo", "Bar")
    assert Cafe.get(:test_cache, "Foo") == {:ok, "Bar"}
  end
end
