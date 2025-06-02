defmodule Snipex.Snippet do
  @enforce_keys [:id, :name, :code]
  @derive Jason.Encoder
  defstruct [:id, :name, :code, :tag]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          code: String.t(),
          tag: String.t() | nil
        }
end
