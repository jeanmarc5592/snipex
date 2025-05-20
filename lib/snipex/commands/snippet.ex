defmodule Snipex.Commands.Snippet do
  def handle(["add" | _opts]) do
    IO.puts("ADD NEW SNIPPET")
  end

  def handle(["edit" | _opts]) do
    IO.puts("EDIT SNIPPET")
  end

  def handle(["delete" | _id_or_name]) do
    IO.puts("DELETE SNIPPET")
  end

  def handle(["copy" | _id_or_name]) do
    IO.puts("COPY SNIPPET TO CLIPBOARD")
  end

  def handle(["list" | _opts]) do
    IO.puts("LIST SNIPPETS")
  end

  def handle(["show" | _id_or_name]) do
    IO.puts("SHOW DETAILS OF A SNIPPET")
  end

  def handle(["search" | _query]) do
    IO.puts("FUZZY SEARCH BY QUERY")
  end
end
