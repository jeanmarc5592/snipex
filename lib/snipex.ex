defmodule Snipex do
  @moduledoc """
  Documentation for `Snipex`.
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
