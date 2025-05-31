defmodule Snipex.Helpers.Snippet do
  alias Snipex.Helpers.General, as: GeneralHelpers

  def get_id_from_output(output) do
    uuid_regex = ~r/\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\b/
    Regex.run(uuid_regex, output)
  end

  def count_rows_from_output(output) do
    row_regex = ~r/^[0-9a-f\-]{36} \|/

    output
    |> String.split("\n")
    |> Enum.count(fn row -> Regex.match?(row_regex, row) end)
  end

  def add_test_snippet(name \\ "Test snippet 2") do
    GeneralHelpers.execute([
      "snippet",
      "add",
      "--name",
      name,
      "--code",
      "IO.puts(\"Hello\")"
    ])
  end

  def add_multiple_test_snippets(amount \\ 5) when amount > 1 and amount <= 10 do
    Enum.each(1..amount, fn index -> add_test_snippet("Snippet #{index}") end)
  end
end
