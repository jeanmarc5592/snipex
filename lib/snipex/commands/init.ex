defmodule Snipex.Commands.Init do
  alias Snipex.Storage

  def handle(), do: initialize()

  defp initialize() do
    Storage.init()
  end
end
