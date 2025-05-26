defmodule Snipex.Utils.UserInput do
  @moduledoc """
  Provides utility functions for validating command-line input options.

  This module helps ensure required and optional switches are properly handled,
  offering helpful error messages for missing or invalid options.
  """

  @doc """
  Validates a list of CLI options against required and optional switches.

  Returns `{:ok, parsed}` if all validations pass. Otherwise, returns an error tuple
  with a descriptive message for either invalid or missing switches.

  ## Parameters

    - `input`: A list of CLI arguments (e.g., `["--name", "Example"]`).
    - `switches`: A keyword list defining required and optional switches.

      Example:
      ```elixir
      validate_switches(opts, required: [name: :string], optional: [code: :string])
      ```

  ## Returns

    - `{:ok, parsed}` if validation is successful.
    - `{:error, :unallowed_switches}` if invalid switches are found.
    - `{:error, :missing_required_switches}` if required switches are missing.

  ## Example

      iex> validate_switches(["--name", "Example"], required: [name: :string])
      {:ok, [name: "Example"]}
  """
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
