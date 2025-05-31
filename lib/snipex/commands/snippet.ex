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
    * `search --name` – searches snippets by name
  """
  @spec handle([String.t()]) :: :ok | :error | nil
  def handle(args)

  def handle(["add" | opts]) when is_list(opts) do
    required_switches = [name: :string, code: :string]

    with {:ok, data} <- UserInput.validate_switches(opts, required: required_switches),
         {:ok, snippet} <- Storage.insert(Map.new(data), :snippets) do
      IO.puts("✅ Snippet successfully saved with id '#{snippet.id}'!")
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
      {:error, :duplicate_content} -> :error
      {:error, :invalid_data} -> :error
    end
  end

  def handle(["edit" | [id | opts]]) when is_binary(id) and is_list(opts) do
    optional_switches = [name: :string, code: :string]

    with true <- UserInput.valid_uuid?(id),
         {:ok, updates} <- UserInput.validate_switches(opts, optional: optional_switches),
         {:ok, _snippet} <- Storage.edit(id, updates, :snippets) do
      IO.puts("✅ Snippet with id '#{id}' successfully edited!")
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
      {:error, :not_found} -> :error
      false -> :error
    end
  end

  def handle(["delete" | [id]]) when is_binary(id) do
    if UserInput.valid_uuid?(id) do
      case Storage.delete_by_id(id, :snippets) do
        {:ok, _} -> IO.puts("✅ Snippet with id '#{id}' succesfully deleted!")
        {:error, :not_found} -> :error
      end
    end
  end

  def handle(["copy" | [id]]) when is_binary(id) do
    if UserInput.valid_uuid?(id) do
      case Storage.find_by_id(id, :snippets) do
        {:ok, %{id: _, name: _, code: code}} ->
          Clipboard.copy(code)
          IO.puts("✅ Snippet with id '#{id}' copied to clipboard.")

        {:error, :not_found} ->
          :error
      end
    end
  end

  def handle(["list"]) do
    snippets = Storage.list_all(:snippets)
    Printer.print_list(snippets, :snippets)
  end

  def handle(["show" | [id]]) when is_binary(id) do
    if UserInput.valid_uuid?(id) do
      case Storage.find_by_id(id, :snippets) do
        {:ok, snippet} -> Printer.print_detail(snippet, :snippets)
        {:error, :not_found} -> :error
      end
    end
  end

  def handle(["search" | opts]) when is_list(opts) do
    required_switches = [name: :string]

    with {:ok, data} <- UserInput.validate_switches(opts, required: required_switches) do
      cond do
        name = Keyword.get(data, :name) ->
          snippets = Storage.search_by_name(name, :snippets)
          Printer.print_list(snippets, :snippets)

        true ->
          :ok
      end
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
    end
  end
end
