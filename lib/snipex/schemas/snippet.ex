defmodule Snipex.Schemas.Snippet do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "snippets" do
    field(:name, :string)
    field(:code, :string)
    timestamps()
  end
end
