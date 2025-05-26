defmodule Snipex do
  @moduledoc """
    Handles all snippet-related CLI commands for the Snipex tool.

    ## Notes

    - Commands use standard option parsing (`OptionParser`) and support both required and optional switches.
    - Validation is handled via `Snipex.Utils.UserInput`.
    - Output is formatted through `Snipex.Printer`.
  """
  alias Snipex.Commands.Snippet, as: Snippet
  alias Snipex.Commands.Init, as: Init

  def main(args) do
    case args do
      ["init"] -> Init.handle()
      ["snippet" | rest] -> Snippet.handle(rest)
      _ -> "Snipex CLI"
    end
  end
end
