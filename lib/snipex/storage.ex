defmodule Snipex.Storage do
  alias Snipex.Utils.FileSystem, as: FS

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

  defp list_all_data(file) do
    {:ok, content} = FS.read_file(file)
    Jason.decode(content)
  end

  defp insert_data(new_data, file, target_struct) do
    {:ok, content} = FS.read_file(file)
    {:ok, decoded_content} = Jason.decode(content)

    existing_data =
      Enum.map(decoded_content, fn item -> struct(target_struct, atomize_keys(item)) end)

    case find_duplicates(existing_data, "name", new_data) do
      {:ok, _} ->
        json = Jason.encode!([new_data | existing_data], pretty: true)
        FS.write_file(file, json)
        {:ok, new_data}

      {:error, reason} ->
        {:error, reason}
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
