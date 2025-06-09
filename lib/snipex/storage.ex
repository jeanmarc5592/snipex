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

  # @base_path System.get_env("SNIPEX_DATA_DIR") || Path.expand("../../data", __DIR__)
  # @snippets_path Path.join(@base_path, "snippets.json")
  # @storage_paths [
  #   snippets: @snippets_path
  # ]

  defp base_path, do: System.get_env("SNIPEX_STORAGE_PATH") || Path.expand("../../data", __DIR__)
  defp snippets_path, do: Path.join(base_path(), "snippets.json")
  defp tags_path, do: Path.join(base_path(), "tags.json")

  @doc """
  Initializes the storage directory and JSON files.

  Creates the base storage directory and empty JSON files if they don’t exist.
  """
  @spec init() :: :ok
  # def init() do
  #   File.mkdir_p!(@base_path)

  #   Enum.each(@storage_paths, fn {_, path} ->
  #     if !File.exists?(path), do: File.write!(path, "[]")
  #   end)

  #   IO.puts("✅ Initialized snipex data storage.")

  #   :ok
  # end
  def init do
    File.mkdir_p!(base_path())

    Enum.each([{:snippets, snippets_path()}, {:tags, tags_path()}], fn {_, path} ->
      if !File.exists?(path), do: File.write!(path, "[]")
    end)

    IO.puts("✅ Initialized snipex data storage.")
    :ok
  end

  @doc """
  Inserts a new entry into storage (`:snippets` or `:tags`).

  Fails if an entry with the same name already exists.

  ## Parameters

    - `data`: A map containing the required fields (e.g., `:name` and `:code`)
    - `type`: Either `:snippets` or `:tags`, indicating the storage target

  ## Returns

    - `{:ok, entry}` on success
    - `{:error, :duplicate_content}` if the name already exists
    - `{:error, :invalid_data}` for missing or invalid input
  """
  @spec insert(%{name: String.t(), code: String.t(), tag: String.t() | nil}, :snippets) ::
          {:ok, Snipex.Snippet.t()} | {:error, :duplicate_content | :invalid_data | :not_found}
  def insert(%{name: name, code: code, tag: tag}, :snippets)
      when is_binary(name) and is_binary(code) do
    case find_by_name(tag, :tags) do
      {:ok, _tag} ->
        %Snipex.Snippet{id: UUID.uuid4(), name: name, code: code, tag: tag}
        |> insert_data(snippets_path(), Snipex.Snippet)

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def insert(_, :snippets), do: {:error, :invalid_data}

  @spec insert(%{name: String.t()}, :tags) ::
          {:ok, Snipex.Tag.t()} | {:error, :duplicate_content | :invalid_data}
  def insert(%{name: name}, :tags) when is_binary(name) do
    %Snipex.Tag{id: UUID.uuid4(), name: name}
    |> insert_data(tags_path(), Snipex.Tag)
  end

  def insert(_, :tags), do: {:error, :invalid_data}

  @doc """
  Edits an existing entry (`:snippets` or `:tags`) by ID with the provided updates.

  When editing a tag, all associated snippets with that tag will have their `tag` field updated accordingly.

  ## Parameters

    - `id`: The ID of the entry to update
    - `updates`: A list of `{field, value}` tuples to update (e.g., `:name`, `:code`)
    - `type`: Either `:snippets` or `:tags`, indicating the storage target

  ## Returns

    - `{:ok, updated_entry}` on success
    - `{:error, :not_found}` if the entry ID is not found
  """
  @spec edit(String.t(), [{:name | :code | :tag, String.t() | nil}], :snippets) ::
          {:ok, Snipex.Snippet.t()} | {:error, :not_found}
  def edit(id, updates, :snippets) when is_binary(id) and is_list(updates) do
    edit_data(id, updates, snippets_path(), :snippet)
  end

  @spec edit(String.t(), [{:name, String.t()}], :tags) ::
          {:ok, Snipex.Tag.t()} | {:error, :not_found}
  def edit(id, updates, :tags) when is_binary(id) and is_list(updates) do
    edit_data(id, updates, tags_path(), :tag)
  end

  @doc """
  Lists all existing data in storage.

  ## Returns

    - List of all stored snippets or tags as a list of maps
  """
  @spec list_all(:snippets) :: [Snipex.Snippet.t()]
  def list_all(:snippets) do
    list_all_data(snippets_path())
  end

  @spec list_all(:tags) :: [Snipex.Tag.t()]
  def list_all(:tags) do
    list_all_data(tags_path())
  end

  @doc """
  Filters snippets by a given tag.

  Use `"untagged"` as the tag to retrieve all snippets without a tag.

  ## Parameters

    - `tag`: The tag name or `"untagged"` to filter by.
    - `:snippets`: Indicates the type of data to filter.

  ## Returns

    - `{:ok, snippets}`: A list of matching snippets
  """
  @spec filter_by(String.t(), :snippets) :: {:ok, [Snipex.Snippet.t()]}
  def filter_by("untagged", :snippets) do
    find_snippets_by_tag(nil)
  end

  @spec filter_by(String.t(), :snippets) :: {:ok, [Snipex.Snippet.t()]}
  def filter_by(tag, :snippets) when is_binary(tag) do
    find_snippets_by_tag(tag)
  end

  @doc """
  Finds a snippet by its ID.

  ## Returns

    - `{:ok, snippet}` if found
    - `{:error, :not_found}` if not found
  """
  @spec find_by_id(String.t(), :snippets) :: {:ok, Snipex.Snippet.t()} | {:error, :not_found}
  def find_by_id(id, :snippets) when is_binary(id) do
    find_data_by_id(id, snippets_path(), :snippet)
  end

  @doc """
  Finds a tag by its name.

  ## Parameters

    - `name`: The name of the tag to look for.
    - `:tags`: Specifies that the search is in the tags storage.

  ## Returns

    - `{:ok, tag}` if found
    - `{:error, :not_found}` if no tag matches the name
  """
  @spec find_by_name(String.t(), :tags) :: {:ok, Snipex.Tag.t()} | {:error, :not_found}
  def find_by_name(name, :tags) when is_binary(name) do
    find_data_by_name(name, tags_path(), :tag)
  end

  @doc """
  Deletes an existing entry (`:snippets` or `:tags`) by ID.

  When deleting a tag, the operation will fail if any snippet is currently associated with it,
  unless a force-delete is wanted through the "force: true" option.

  ## Parameters

    - `id`: The ID of the entry to delete
    - `type`: Either `:snippets` or `:tags`, indicating the storage target

  ## Returns

    - `{:ok, deleted_entry}` on success
    - `{:error, :not_found}` if the entry ID is not found
    - `{:error, :in_use}` if trying to delete a tag that is still used by snippets (only applies to `:tags`)
  """
  @spec delete_by_id(String.t(), :snippets) :: {:ok, Snipex.Snippet.t()} | {:error, :not_found}
  def delete_by_id(id, :snippets) when is_binary(id) do
    delete_data_by_id(id, snippets_path(), :snippet)
  end

  @spec delete_by_id(String.t(), :tags) :: {:ok, Snipex.Tag.t()} | {:error, :not_found | :in_use}
  def delete_by_id(id, :tags) when is_binary(id) do
    with {:ok, tag} <- find_data_by_id(id, tags_path(), :tag),
         {:ok, snippets} when snippets == [] <- find_snippets_by_tag(tag.name) do
      delete_data_by_id(id, tags_path(), :tags)
    else
      {:error, :not_found} ->
        {:error, :not_found}

      _snippets ->
        IO.puts("❌ Deletion denied. The tag with id '#{id}' is in use.")
        {:error, :in_use}
    end
  end

  @spec delete_by_id(String.t(), :tags, force: true) ::
          {:ok, Snipex.Tag.t()} | {:error, :not_found}
  def delete_by_id(id, :tags, force: true) when is_binary(id) do
    with {:ok, tag} <- find_data_by_id(id, tags_path(), :tag),
         {:ok, snippets} <- find_snippets_by_tag(tag.name) do
      Enum.each(snippets, fn %{id: id} ->
        _ = Snipex.Storage.edit(id, [tag: nil], :snippets)
      end)

      delete_data_by_id(id, tags_path(), :tags)

      {:ok, tag}
    else
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  @doc """
  Searches for snippets by a fuzzy-matching name.

  Each character in the query must be present in the target name.

  ## Returns

    - A list of matching snippets
  """
  @spec search_by_name(String.t(), :snippets) :: [map]
  def search_by_name(name, :snippets) when is_binary(name) do
    search_data_by_name(name, snippets_path())
  end

  @doc false
  @spec list_all_data(String.t()) :: [map()]
  defp list_all_data(file) when is_binary(file) do
    file
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(fn item -> atomize_keys(item) end)
  end

  @doc false
  @spec find_data_by_id(String.t(), String.t(), atom()) :: {:ok, map()} | {:error, :not_found}
  defp find_data_by_id(id, file, type) when is_binary(id) and is_binary(file) and is_atom(type) do
    existing_data =
      file
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item -> atomize_keys(item) end)

    case Enum.find_index(existing_data, fn item -> item.id == id end) do
      nil ->
        IO.puts("❌ #{type} with id '#{id}' doesn't exist.")
        {:error, :not_found}

      index ->
        item = Enum.at(existing_data, index)
        {:ok, item}
    end
  end

  @doc false
  @spec find_data_by_name(String.t(), String.t(), atom()) :: {:ok, map()} | {:error, :not_found}
  defp find_data_by_name(name, file, type)
       when is_binary(name) and is_binary(file) and is_atom(type) do
    existing_data =
      file
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item -> atomize_keys(item) end)

    case Enum.find_index(existing_data, fn item -> item.name == name end) do
      nil ->
        IO.puts("❌ #{type} with name '#{name}' doesn't exist.")
        {:error, :not_found}

      index ->
        item = Enum.at(existing_data, index)
        {:ok, item}
    end
  end

  @doc false
  @spec find_snippets_by_tag(String.t() | nil) :: {:ok, list()}
  defp find_snippets_by_tag(tag) do
    snippets =
      snippets_path()
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item -> atomize_keys(item) end)
      |> Enum.filter(fn snippet -> snippet.tag == tag end)

    {:ok, snippets}
  end

  @doc false
  @spec insert_data(struct(), String.t(), module()) ::
          {:ok, struct()} | {:error, :duplicate_content}
  defp insert_data(new_data, file, target_struct)
       when is_struct(new_data) and is_binary(file) and is_atom(target_struct) do
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
  @spec edit_data(String.t(), [{atom(), String.t() | nil}], String.t(), atom()) ::
          {:ok, map()} | {:error, :not_found}
  defp edit_data(id, updates, file, type)
       when is_binary(id) and is_list(updates) and is_binary(file) and is_atom(type) do
    existing_data =
      file
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item -> atomize_keys(item) end)

    case Enum.find_index(existing_data, fn item -> item.id == id end) do
      nil ->
        IO.puts("❌ #{type} with id '#{id}' doesn't exist.")
        {:error, :not_found}

      index ->
        original_item = Enum.at(existing_data, index)

        update_map =
          Enum.reduce(updates, %{}, fn
            {key, value}, acc when is_atom(key) and (is_binary(value) or is_nil(value)) ->
              Map.put(acc, key, value)

            _, acc ->
              acc
          end)

        updated_item = Map.merge(original_item, update_map)
        updated_list = List.replace_at(existing_data, index, updated_item)

        json = Jason.encode!(updated_list, pretty: true)
        File.write!(file, json)

        {:ok, updated_item}
    end
  end

  @doc false
  @spec delete_data_by_id(String.t(), String.t(), atom()) :: {:ok, map()} | {:error, :not_found}
  defp delete_data_by_id(id, file, type)
       when is_binary(id) and is_binary(file) and is_atom(type) do
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
        IO.puts("❌ #{type} with id '#{id}' couldn't be deleted. Not found!")
        {:error, :not_found}
    end
  end

  @doc false
  @spec search_data_by_name(String.t(), String.t()) :: [map()]
  defp search_data_by_name(name, file) when is_binary(name) and is_binary(file) do
    file
    |> File.read!()
    |> Jason.decode!()
    |> Enum.filter(fn snippet -> fuzzy_includes?(snippet["name"], name) end)
  end

  @doc false
  @spec atomize_keys(map()) :: map()
  defp atomize_keys(map) when is_map(map) do
    Enum.map(map, fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.into(%{})
  end

  @doc false
  @spec find_duplicates([map()], String.t(), map()) :: {:ok, map()} | {:error, :duplicate_content}
  defp find_duplicates(data, key, item_to_insert)
       when is_list(data) and is_binary(key) and is_map(item_to_insert) do
    atom_key = String.to_atom(key)

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
  @spec fuzzy_includes?(String.t(), String.t()) :: boolean()
  defp fuzzy_includes?(text, query) when is_binary(text) and is_binary(query) do
    query
    |> String.downcase()
    |> String.graphemes()
    |> Enum.all?(fn data -> String.contains?(String.downcase(text), data) end)
  end
end
