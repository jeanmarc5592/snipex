defmodule Snipex.Commands.Snippet do
  alias Snipex.Storage
  alias Snipex.Utils.UserInput, as: UserInput

  def handle(["add" | opts]), do: add_snippet(opts)

  def handle(["edit" | _opts]) do
    IO.puts("EDIT SNIPPET")
  end

  def handle(["delete" | [id]]) do
    if valid_uuid?(id) do
      delete_snippet(id)
    else
      IO.puts("❌ Invalid UUID.")
    end
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

  defp delete_snippet(id) do
    case Storage.delete_by_id(:snippets, id) do
      {:ok, _} -> IO.puts("✅ Item with id '#{id}' succesfully deleted.")
      {:error, :not_found} -> IO.puts("❌ Item with id '#{id}' couldn't be deleted. Not found")
    end
  end

  defp valid_uuid?(id) do
    uuid_regex = ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    Regex.match?(uuid_regex, id)
  end
end
