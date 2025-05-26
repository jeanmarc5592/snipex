defmodule Snipex.Commands.Snippet do
  @moduledoc """
  Provides CLI command handling for managing code snippets in Snipex.

  This module handles subcommands under `snippet`, including adding, editing,
  deleting, listing, showing, copying, and searching snippets.
  """

  alias Snipex.Storage
  alias Snipex.Utils.UserInput, as: UserInput
  alias Snipex.Printer

  @doc """
  Handles all `snippet` subcommands:

    * `add --name --code` – adds a new snippet
    * `edit <id> [--name] [--code]` – updates a snippet
    * `delete <id>` – deletes a snippet by ID
    * `copy <id>` – copies snippet code to clipboard
    * `list` – lists all snippets
    * `show <id>` – displays snippet details
    * `search [--name]` – searches snippets by name
  """
  def handle(args)

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

  def handle(["search" | opts]), do: search_snippets(opts)

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

  @doc false
  defp list_snippets() do
    snippets = Storage.list_all(:snippets)
    Printer.print_list(snippets, :snippets)
  end

  @doc false
  defp show_snippet(id) do
    case Storage.find_by_id(:snippets, id) do
      {:ok, snippet} ->
        Printer.print_detail(snippet, :snippets)

      {:error, :not_found} ->
        :error
    end
  end

  @doc false
  defp search_snippets(opts) do
    optional_switches = [name: :string, code: :string]

    with {:ok, data} <- UserInput.validate_switches(opts, optional: optional_switches) do
      cond do
        name = Keyword.get(data, :name) ->
          snippets = Storage.search_by_name(:snippets, name)
          Printer.print_list(snippets, :snippets)

        true ->
          :ok
      end
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
    end
  end

  @doc false
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
