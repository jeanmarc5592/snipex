defmodule Snipex do
  @moduledoc """
  Documentation for `Snipex`.
  """
  alias Snipex.Commands.Snippet, as: Snippet

  def main(args) do
    case args do
      ["snippet" | rest] -> Snippet.handle(rest)
      _ -> "Snipex CLI"
    end
  end
end
