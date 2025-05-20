defmodule Snipex.Commands.Snippet do
  alias Snipex.Storage
  alias Snipex.Utils.UserInput, as: UserInput

  def handle(["add" | opts]), do: add_snippet(opts)

  def handle(["edit" | _opts]) do
    IO.puts("EDIT SNIPPET")
  end

  def handle(["delete" | _id_or_name]) do
    IO.puts("DELETE SNIPPET")
  end

  def handle(["copy" | _id_or_name]) do
    IO.puts("COPY SNIPPET TO CLIPBOARD")
  end

  def handle(["list" | _opts]) do
    IO.puts("LIST SNIPPETS")
  end

  def handle(["show" | _id_or_name]) do
    IO.puts("SHOW DETAILS OF A SNIPPET")
  end

  def handle(["search" | _query]) do
    IO.puts("FUZZY SEARCH BY QUERY")
  end

  defp add_snippet(opts) do
    {:ok, data} = UserInput.validate_switches(opts, name: :string, code: :string)

    result =
      data
      |> Map.new()
      |> Storage.insert(:snippets)

    case result do
      {:ok, _new_snippet} -> IO.puts("✅ Snippet successfully saved!")
    end
  end
end
