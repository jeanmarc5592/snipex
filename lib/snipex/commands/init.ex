defmodule Snipex.Commands.Init do
  @moduledoc """
  Handles the initialization of the project.
  """

  alias Snipex.Storage

  @doc """
  Triggers the initialization process for Snipex storage.

  Delegates to the private `initialize/0` function, which calls `Snipex.Storage.init/0`.

  ## Example

      iex> Snipex.Commands.Init.handle()
      :ok
  """
  def handle(), do: initialize()

  @doc false
  defp initialize() do
    Storage.init()
  end
end
