defmodule Snipex.Snippet do
  @enforce_keys [:id, :name, :code]
  @derive Jason.Encoder
  defstruct [:id, :name, :code]
end
