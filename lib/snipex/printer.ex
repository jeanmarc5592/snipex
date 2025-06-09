defmodule Snipex.Printer do
  @moduledoc """
  Provides utility functions for formatting and printing data to the console.

  This module handles displaying data in both list and detailed views,
  offering structured output for a better command-line experience.
  """

  @doc """
  Prints a formatted table of snippet IDs and names.

  Each snippet is displayed in a fixed-width row with dividers between entries.

  ## Parameters

    - `list`: A list of maps representing snippet data.
    - `:snippets`: Atom indicating the data type (currently only `:snippets` is supported).

  ## Example

      Snipex.Printer.print_list(snippets, :snippets)
  """
  def print_list(list, :snippets) do
    total_length = length(list)

    IO.puts("\nID                                   | NAME                 | TAG")
    IO.puts(String.duplicate("-", 100))

    list
    |> Enum.with_index()
    |> Enum.each(fn {%{:id => id, :name => name, :tag => tag}, index} ->
      IO.puts("#{id} | #{String.pad_trailing(name, 20)} | #{String.pad_trailing(tag || "—", 8)}")
      if index < total_length - 1, do: IO.puts(String.duplicate("-", 100))
    end)
  end

  def print_list(list, :tags) do
    total_length = length(list)

    IO.puts("\nID                                   | NAME")
    IO.puts(String.duplicate("-", 80))

    list
    |> Enum.with_index()
    |> Enum.each(fn {%{:id => id, :name => name}, index} ->
      IO.puts("#{id} | #{String.pad_trailing(name, 14)}")
      if index < total_length - 1, do: IO.puts(String.duplicate("-", 80))
    end)
  end

  @doc """
  Prints a detailed view of a single snippet.

  Displays the snippet's name and ID, followed by the code block.

  ## Parameters

    - `%{id: id, name: name, code: code}`: A snippet struct or map with required fields.
    - `:snippets`: Atom indicating the data type (currently only `:snippets` is supported).

  ## Example

      Snipex.Printer.print_detail(snippet, :snippets)
  """
  def print_detail(%{id: id, name: name, code: code}, :snippets) do
    IO.puts("\"#{name}\" [#{id}]\n")
    IO.puts("#{code}")
  end
end
