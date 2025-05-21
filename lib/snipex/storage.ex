defmodule Snipex.Storage do
  alias Snipex.Utils.FileSystem, as: FS

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

  defp insert_data(new_data, file, target_struct) do
    {:ok, content} = FS.read_file(file)
    {:ok, decoded_content} = Jason.decode(content)

    # TODO: Search for duplicated names?

    existing_data =
      Enum.map(decoded_content, fn item -> struct(target_struct, atomize_keys(item)) end)

    json = Jason.encode!([new_data | existing_data], pretty: true)

    FS.write_file(file, json)
  end

  defp atomize_keys(map) do
    Enum.map(map, fn {key, value} -> {String.to_atom(key), value} end)
    |> Enum.into(%{})
  end
end
