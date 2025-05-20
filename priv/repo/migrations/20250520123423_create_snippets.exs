defmodule Snipex.Repo.Migrations.CreateSnippets do
  use Ecto.Migration

  def change do
    create table(:snippets, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:code, :string)
      timestamps(type: :utc_datetime)
    end

    create index("snippets", [:id])
    create index("snippets", [:name])
    create index("snippets", [:code])
    create index("snippets", [:inserted_at])
    create index("snippets", [:updated_at])
  end
end
