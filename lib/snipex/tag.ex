defmodule Snipex.Tag do
  @enforce_keys [:id, :name]
  @derive Jason.Encoder
  defstruct [:id, :name]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t()
        }
end
