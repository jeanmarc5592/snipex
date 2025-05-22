defmodule Snipex.Utils.UserInput do
  def validate_switches(input, switches) do
    required_switches = Keyword.get(switches, :required, [])
    optional_switches = Keyword.get(switches, :optional, [])
    all_switches = required_switches ++ optional_switches

    {parsed, _, invalid} = OptionParser.parse(input, strict: all_switches)

    missing_required_switches =
      required_switches
      |> Enum.map(fn {key, _type} -> key end)
      # If a required switch is present it will filtered out
      |> Enum.filter(fn key -> !Keyword.has_key?(parsed, key) end)

    cond do
      invalid != [] ->
        IO.puts("❌ Invalid options: #{inspect(invalid)}")
        {:error, :unallowed_switches}

      missing_required_switches != [] ->
        IO.puts("❌ Missing required options: #{inspect(missing_required_switches)}")
        {:error, :missing_required_switches}

      true ->
        {:ok, parsed}
    end
  end
end
