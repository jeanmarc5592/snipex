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

  def handle(["edit" | [id | opts]]) do
    optional_switches = [name: :string]

    with true <- UserInput.valid_uuid?(id),
         {:ok, updates} <- UserInput.validate_switches(opts, optional: optional_switches),
         {:ok, _tag} <- Storage.edit(id, updates, :tags) do
      IO.puts("✅ Tag with id '#{id}' successfully edited!")
    else
      {:error, :unallowed_switches} -> :error
      {:error, :missing_required_switches} -> :error
      {:error, :not_found} -> :error
      false -> :error
    end
  end

  def handle(["delete" | [id]]) do
    with true <- UserInput.valid_uuid?(id),
         {:ok, _tag} <- Storage.delete_by_id(id, :tags) do
      IO.puts("✅ Tag with id '#{id}' succesfully deleted!")
    else
      {:error, :not_found} -> :error
      {:error, :in_use} -> :error
    end
  end
end
