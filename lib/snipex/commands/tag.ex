defmodule Snipex.Commands.Tag do
  alias Snipex.Storage
  alias Snipex.Utils.UserInput, as: UserInput

  def handle(args)

  def handle(["add" | opts]) do
    required_switches = [name: :string]

    with {:ok, data} <- UserInput.validate_switches(opts, required: required_switches),
         {:ok, tag} <- Storage.insert(Map.new(data), :tags) do
      IO.puts("✅ Tag successfully saved with id '#{tag.id}'!")
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
      {:error, :duplicate_content} -> :error
      {:error, :invalid_data} -> :error
    end
  end
end
