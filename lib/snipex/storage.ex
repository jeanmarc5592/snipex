defmodule Snipex.Storage do
  # TODO: Control via .env
  # @base_path Path.join(System.user_home!(), ".snipex")
  @base_path Path.expand("../../data", __DIR__)
  @snippets_path Path.join(@base_path, "snippets.json")
  @storage_paths [
    snippets: @snippets_path
  ]

  def init() do
    File.mkdir_p!(@base_path)

    Enum.each(@storage_paths, fn {_, path} ->
      if !File.exists?(path), do: File.write!(path, "[]")
    end)

    IO.puts("✅ Initialized snipex data storage.")

    :ok
  end

  def insert(%{name: name, code: code}, :snippets) do
    %Snipex.Snippet{id: UUID.uuid4(), name: name, code: code}
    |> insert_data(@snippets_path, Snipex.Snippet)
  end

  def list_all(:snippets), do: list_all_data(@snippets_path)

  def delete_by_id(:snippets, id), do: delete_data_by_id(@snippets_path, id)

  defp list_all_data(file) do
    file
    |> File.read!()
    |> Jason.decode!()
  end

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

  defp delete_data_by_id(file, id) do
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

  defp atomize_keys(map) do
    Enum.map(map, fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.into(%{})
  end

  defp find_duplicates(data, key, item_to_insert) do
    atom_key = String.to_existing_atom(key)

    case Enum.find(data, fn item ->
           Map.get(item, atom_key) == Map.get(item_to_insert, atom_key)
         end) do
      nil ->
        {:ok, item_to_insert}

      _ ->
        IO.puts(
          "❌ Snippet with the #{key} '#{Map.get(item_to_insert, atom_key)}' already exists."
        )

        {:error, :duplicate_content}
    end
  end
end
