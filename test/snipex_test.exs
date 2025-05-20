defmodule SnipexTest do
  use ExUnit.Case
  doctest Snipex

  test "greets the world" do
    assert Snipex.hello() == :world
  end
end
