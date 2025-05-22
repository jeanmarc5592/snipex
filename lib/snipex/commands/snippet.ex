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

  def handle(["list"]), do: list_snippets()

  def handle(["show" | _id_or_name]) do
    IO.puts("SHOW DETAILS OF A SNIPPET")
  end

  def handle(["search" | _query]) do
    IO.puts("FUZZY SEARCH BY QUERY")
  end

  defp add_snippet(opts) do
    with {:ok, data} <- UserInput.validate_switches(opts, name: :string, code: :string),
         {:ok, _snippet} <- Storage.insert(Map.new(data), :snippets) do
      IO.puts("✅ Snippet successfully saved!")
    else
      {:error, :unallowed_switches} -> :error
      {:error, :duplicate_content} -> :error
    end
  end

  defp list_snippets() do
    snippets = Storage.list_all(:snippets)
    total_length = length(snippets)

    IO.puts("\nID                                   | NAME")
    IO.puts(String.duplicate("-", 80))

    snippets
    |> Enum.with_index()
    |> Enum.each(fn {%{"id" => id, "name" => name, "code" => _}, index} ->
      IO.puts("#{id} | #{String.pad_trailing(name, 14)}")
      if index < total_length - 1, do: IO.puts(String.duplicate("-", 80))
    end)
  end
end
