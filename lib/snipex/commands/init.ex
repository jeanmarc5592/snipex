defmodule Snipex.Commands.Init do
  alias Snipex.Defaults

  def handle() do
    File.mkdir_p!(Path.expand("../../../data", __DIR__))

    Enum.each(Defaults.storage_paths(), fn {_, path} ->
      if !File.exists?(path), do: File.write!(path, "[]")
    end)

    IO.puts("✅ Initialized snipex data storage.")

    :ok
  end
end
