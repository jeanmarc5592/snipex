defmodule Snipex.Printer do
  def print_list(list, :snippets) do
    total_length = length(list)

    IO.puts("\nID                                   | NAME")
    IO.puts(String.duplicate("-", 80))

    list
    |> Enum.with_index()
    |> Enum.each(fn {%{"id" => id, "name" => name, "code" => _}, index} ->
      IO.puts("#{id} | #{String.pad_trailing(name, 14)}")
      if index < total_length - 1, do: IO.puts(String.duplicate("-", 80))
    end)
  end
end
