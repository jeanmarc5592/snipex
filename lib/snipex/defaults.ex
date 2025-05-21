defmodule Snipex.Defaults do
  def storage_paths() do
    base_path = Path.expand("../../data", __DIR__)

    [snippets: Path.join(base_path, "snippets.json")]
  end
end
