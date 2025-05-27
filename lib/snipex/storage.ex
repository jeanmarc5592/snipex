defmodule Snipex.Storage do
  @moduledoc """
  Provides functions for managing snippet data storage in the Snipex application.

  Handles reading, writing, editing, deleting, and searching snippet entries stored
  as JSON files. This module abstracts file operations and ensures proper data handling
  and formatting.

  ## Features

    * Initializes storage directories and files
    * Inserts new snippet entries with duplicate checks
    * Edits and deletes snippets by ID
    * Lists all stored snippets
    * Finds snippets by ID
    * Performs fuzzy name-based searches
  """

  # TODO: Control via .env
  # @base_path Path.join(System.user_home!(), ".snipex")
  @base_path Path.expand("../../data", __DIR__)
  @snippets_path Path.join(@base_path, "snippets.json")
  @storage_paths [
    snippets: @snippets_path
  ]

  @doc """
  Initializes the storage directory and JSON files.

  Creates the base storage directory and empty JSON files if they don’t exist.
  """
  def init() do
    File.mkdir_p!(@base_path)

    Enum.each(@storage_paths, fn {_, path} ->
      if !File.exists?(path), do: File.write!(path, "[]")
    end)

    IO.puts("✅ Initialized snipex data storage.")

    :ok
  end

  @doc """
  Inserts a new snippet into storage.

  Fails if a snippet with the same name already exists.

  ## Parameters

    - `data`: A map with `:name` and `:code` keys
    - `:snippets`: The atom representing the snippet storage file

  ## Returns

    - `{:ok, snippet}` on success
    - `{:error, :duplicate_content}` if name is already taken
  """
  def insert(%{name: name, code: code}, :snippets) do
    %Snipex.Snippet{id: UUID.uuid4(), name: name, code: code}
    |> insert_data(@snippets_path, Snipex.Snippet)
  end

  @doc """
  Edits an existing snippet by ID with provided updates.

  ## Returns

    - `{:ok, updated_snippet}` on success
    - `{:error, :not_found}` if snippet ID is not found
  """
  def edit(id, updates, :snippets), do: edit_data(id, updates, @snippets_path)

  @doc """
  Lists all snippets in storage.

  ## Returns

    - List of all stored snippets as maps
  """
  def list_all(:snippets), do: list_all_data(@snippets_path)

  @doc """
  Finds a snippet by its ID.

  ## Returns

    - `{:ok, snippet}` if found
    - `{:error, :not_found}` if not found
  """
  def find_by_id(id, :snippets), do: find_data_by_id(id, @snippets_path)

  @doc """
  Deletes a snippet by ID.

  ## Returns

    - `{:ok, deleted_snippet}` if successful
    - `{:error, :not_found}` if ID does not exist
  """
  def delete_by_id(id, :snippets), do: delete_data_by_id(id, @snippets_path)

  @doc """
  Searches for snippets by a fuzzy-matching name.

  Each character in the query must be present in the target name.

  ## Returns

    - A list of matching snippets
  """
  def search_by_name(name, :snippets), do: search_data_by_name(name, @snippets_path)

  @doc false
  defp list_all_data(file) do
    file
    |> File.read!()
    |> Jason.decode!()
  end

  @doc false
  defp find_data_by_id(id, file) do
    existing_data =
      file
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item -> atomize_keys(item) end)

    case Enum.find_index(existing_data, fn item -> item.id == id end) do
      nil ->
        IO.puts("❌ Item with id '#{id}' doesn't exist.")
        {:error, :not_found}

      index ->
        item = Enum.at(existing_data, index)
        {:ok, item}
    end
  end

  @doc false
  defp insert_data(new_data, file, target_struct) do
    existing_data =
      file
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item -> struct(target_struct, atomize_keys(item)) end)

    case find_duplicates(existing_data, "name", new_data) do
      {:ok, _} ->
        json = Jason.encode!([new_data | existing_data], pretty: true)
        File.write!(file, json)
        {:ok, new_data}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc false
  defp edit_data(id, updates, file) do
    existing_data =
      file
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item -> atomize_keys(item) end)

    case Enum.find_index(existing_data, fn item -> item.id == id end) do
      nil ->
        IO.puts("❌ Item with id '#{id}' doesn't exist.")
        {:error, :not_found}

      index ->
        original_item = Enum.at(existing_data, index)
        updated_item = Map.merge(original_item, Map.new(updates))
        updated_list = List.replace_at(existing_data, index, updated_item)

        json = Jason.encode!(updated_list, pretty: true)
        File.write!(file, json)

        {:ok, updated_item}
    end
  end

  @doc false
  defp delete_data_by_id(id, file) do
    existing_data =
      file
      |> File.read!()
      |> Jason.decode!()

    # Returns tuple with two lists (left: where the case is true, right: where the case is false)
    case Enum.split_with(existing_data, fn item -> item["id"] != id end) do
      # If there is a match, it will be in the right list (only one because id's are unique)
      {filtered, [deleted]} ->
        File.write!(file, Jason.encode!(filtered, pretty: true))
        {:ok, deleted}

      # When right list is empty, the item with the id doesn't exist
      {_, []} ->
        {:error, :not_found}
    end
  end

  @doc false
  defp search_data_by_name(name, file) do
    file
    |> File.read!()
    |> Jason.decode!()
    |> Enum.filter(fn snippet -> fuzzy_includes?(snippet["name"], name) end)
  end

  @doc false
  defp atomize_keys(map) do
    Enum.map(map, fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.into(%{})
  end

  @doc false
  defp find_duplicates(data, key, item_to_insert) do
    atom_key = String.to_existing_atom(key)

    case Enum.find(data, fn item ->
           Map.get(item, atom_key) == Map.get(item_to_insert, atom_key)
         end) do
      nil ->
        {:ok, item_to_insert}

      _ ->
        IO.puts("❌ Item with the #{key} '#{Map.get(item_to_insert, atom_key)}' already exists.")
        {:error, :duplicate_content}
    end
  end

  @doc false
  defp fuzzy_includes?(text, query) do
    query
    |> String.downcase()
    |> String.graphemes()
    |> Enum.all?(fn data -> String.contains?(String.downcase(text), data) end)
  end
end
