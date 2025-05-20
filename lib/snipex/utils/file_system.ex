defmodule Snipex.Utils.FileSystem do
  def read_file(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        {:ok, content}

      {:error, :enoent} ->
        IO.puts("❌ No file found at #{file_path}")
        {:error, :not_found}

      {:error, reason} ->
        IO.puts("❌ Error reading file: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def write_file(file_path, content) do
    case File.write(file_path, content) do
      :ok ->
        {:ok, content}

      {:error, reason} ->
        IO.puts("❌ Failed to write to file: #{reason}")
        {:error, reason}
    end
  end
end
