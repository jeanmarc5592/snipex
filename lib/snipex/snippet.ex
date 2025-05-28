defmodule Snipex.Snippet do
  @enforce_keys [:id, :name, :code]
  @derive Jason.Encoder
  defstruct [:id, :name, :code]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          code: String.t()
        }
end
