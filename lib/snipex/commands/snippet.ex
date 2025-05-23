defmodule Snipex.Commands.Snippet do
  alias Snipex.Storage
  alias Snipex.Utils.UserInput, as: UserInput

  def handle(["add" | opts]), do: add_snippet(opts)

  def handle(["edit" | opts]), do: edit_snippet(opts)

  def handle(["delete" | [id]]) do
    if valid_uuid?(id) do
      delete_snippet(id)
    else
      IO.puts("❌ Invalid UUID.")
    end
  end

  def handle(["copy" | [id]]), do: copy_snippet(id)

  def handle(["list"]), do: list_snippets()

  def handle(["show" | [id]]), do: show_snippet(id)

  def handle(["search" | _query]) do
    IO.puts("FUZZY SEARCH BY QUERY")
  end

  defp add_snippet(opts) do
    required_switches = [name: :string, code: :string]

    with {:ok, data} <- UserInput.validate_switches(opts, required: required_switches),
         {:ok, _snippet} <- Storage.insert(Map.new(data), :snippets) do
      IO.puts("✅ Snippet successfully saved!")
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
      {:error, :duplicate_content} -> :error
    end
  end

  def edit_snippet([id | opts]) do
    optional_switches = [name: :string, code: :string]

    with {:ok, updates} <- UserInput.validate_switches(opts, optional: optional_switches),
         {:ok, _snippet} <- Storage.edit(id, updates, :snippets) do
      IO.puts("✅ Snipet successfully edited!")
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
      {:error, :not_found} -> :error
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

  defp show_snippet(id) do
    case Storage.find_by_id(:snippets, id) do
      {:ok, %{id: id, name: name, code: code}} ->
        IO.puts("\"#{name}\" [#{id}]\n")
        IO.puts("#{code}")

      {:error, :not_found} ->
        :error
    end
  end

  defp delete_snippet(id) do
    case Storage.delete_by_id(:snippets, id) do
      {:ok, _} -> IO.puts("✅ Snippet with id '#{id}' succesfully deleted.")
      {:error, :not_found} -> IO.puts("❌ Item with id '#{id}' couldn't be deleted. Not found")
    end
  end

  defp copy_snippet(id) do
    case Storage.find_by_id(:snippets, id) do
      {:ok, %{id: _, name: _, code: code}} ->
        Clipboard.copy(code)
        IO.puts("✅ Snippet with id '#{id}' copied to clipboard.")

      {:error, :not_found} ->
        :error
    end
  end

  defp valid_uuid?(id) do
    uuid_regex = ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    Regex.match?(uuid_regex, id)
  end
end
