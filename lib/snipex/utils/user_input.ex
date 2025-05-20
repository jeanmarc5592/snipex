defmodule Snipex.Utils.UserInput do
  def validate_switches(input, switches) do
    {parsed, _, invalid} = OptionParser.parse(input, strict: switches)

    # TODO: Check if all required switches are present
    # TODO: Handle optional switches

    case invalid do
      [] ->
        {:ok, parsed}

      _ ->
        IO.puts("❌ Invalid options: #{inspect(invalid)}")
        {:error, :unallowed_switches}
    end
  end
end
