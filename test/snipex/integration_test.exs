defmodule Snipex.IntegrationTest do
  use ExUnit.Case
  use Snipex.StorageCase, async: true
  alias Snipex.Helpers.Snippet, as: SnippetHelpers
  alias Snipex.Helpers.General, as: GeneralHelpers

  setup do
    GeneralHelpers.execute(["init"])
    :ok
  end

  describe "snippet add" do
    test "adds a new snippet" do
      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "add",
          "--name",
          "Test Snippet",
          "--code",
          "IO.puts(\"Hello\")"
        ])

      assert exit_code == 0
      assert output =~ "✅"
    end

    test "rejects to add a new snippet when there is one snippet already added with the same name" do
      name = "IO.puts(\"Hello\")"

      {_, _} =
        GeneralHelpers.execute([
          "snippet",
          "add",
          "--name",
          name,
          "--code",
          "IO.puts(\"Hello\")"
        ])

      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "add",
          "--name",
          name,
          "--code",
          "IO.puts(\"Hello\")"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to add a new snippet when there are unallowed switches" do
      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "add",
          "--unallowed-switch",
          "Test snippet"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to add a new snippet when '--code' switch is missing" do
      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "add",
          "--name",
          "Test snippet"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to add a new snippet when '--name' switch is missing" do
      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "add",
          "--code",
          "IO.puts(\"Hello\")"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end
  end

  describe "snippet edit" do
    test "edits an existing snippet" do
      {add_output, 0} = SnippetHelpers.add_test_snippet()

      [id] = SnippetHelpers.get_id_from_output(add_output)

      {edit_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "edit",
          id,
          "--code",
          "IO.puts(\"Hello\")"
        ])

      assert exit_code == 0
      assert edit_output =~ "✅"
    end

    test "rejects to edit an existing snippet when there are unallowed switches" do
      {add_output, 0} = SnippetHelpers.add_test_snippet()

      [id] = SnippetHelpers.get_id_from_output(add_output)

      {edit_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "edit",
          id,
          "--unallowed-switch",
          "IO.puts(\"Updated\")"
        ])

      assert exit_code == 0
      assert edit_output =~ "❌"
    end

    test "rejects do edit an existing snippet when it's not found" do
      id = "c3b54d11-dfc8-42de-8ee4-e786f92bc528"

      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "edit",
          id,
          "--code",
          "IO.puts(\"Updated\")"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects do edit an existing snippet when the id is not a valid uuid" do
      id = "INVALID_ID"

      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "edit",
          id,
          "--code",
          "IO.puts(\"Updated\")"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end
  end

  describe "snippet delete" do
    test "deletes an existing snippet" do
      {add_output, 0} = SnippetHelpers.add_test_snippet()

      [id] = SnippetHelpers.get_id_from_output(add_output)

      {delete_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "delete",
          id
        ])

      assert exit_code == 0
      assert delete_output =~ "✅"
    end

    test "rejects to delete an existing snippet when it's not found" do
      id = "c3b54d11-dfc8-42de-8ee4-e786f92bc528"

      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "delete",
          id
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to delete an existing snippet when the id is not a valid uuid" do
      id = "INVALID_UUID"

      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "delete",
          id
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end
  end

  describe "snippet copy" do
    test "copies an existing snippet to the clipboard" do
      {add_output, 0} = SnippetHelpers.add_test_snippet()

      [id] = SnippetHelpers.get_id_from_output(add_output)

      {copy_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "copy",
          id
        ])

      assert exit_code == 0
      assert copy_output =~ "✅"
    end

    test "rejects to copy an existing snippet to the clipboard when it's not found" do
      id = "c3b54d11-dfc8-42de-8ee4-e786f92bc528"

      {copy_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "copy",
          id
        ])

      assert exit_code == 0
      assert copy_output =~ "❌"
    end

    test "rejects to copy an existing snippet to the when the id is not a valid uuid" do
      id = "INVALID_ID"

      {copy_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "copy",
          id
        ])

      assert exit_code == 0
      assert copy_output =~ "❌"
    end
  end

  describe "snippet list" do
    test "lists all existing snippets" do
      SnippetHelpers.add_multiple_test_snippets(3)

      {output, _} =
        GeneralHelpers.execute([
          "snippet",
          "list"
        ])

      row_count = SnippetHelpers.count_rows_from_output(output)

      assert row_count == 3
    end

    test "lists no rows when there are no existing snippets" do
      {output, _} =
        GeneralHelpers.execute([
          "snippet",
          "list"
        ])

      row_count = SnippetHelpers.count_rows_from_output(output)

      assert row_count == 0
    end
  end

  describe "snippet show" do
    test "shows the details of an existing snippet" do
      {add_output, 0} = SnippetHelpers.add_test_snippet()

      [id] = SnippetHelpers.get_id_from_output(add_output)

      {show_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "show",
          id
        ])

      assert exit_code == 0
      assert show_output =~ "Test snippet 2"
      assert show_output =~ id
      assert show_output =~ ~s|IO.puts("Hello")|
    end

    test "rejects to show the details of an existing snippet if it's not found" do
      id = "c3b54d11-dfc8-42de-8ee4-e786f92bc528"

      {copy_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "show",
          id
        ])

      assert exit_code == 0
      assert copy_output =~ "❌"
    end

    test "rejects to show the details of an existing snippet when the id is not a valid uuid" do
      id = "INVALID_ID"

      {copy_output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "show",
          id
        ])

      assert exit_code == 0
      assert copy_output =~ "❌"
    end
  end

  describe "snippet search" do
    test "lists all snippets that were found through fuzzy search" do
      SnippetHelpers.add_multiple_test_snippets(3)

      {output, _} =
        GeneralHelpers.execute([
          "snippet",
          "search",
          "--name",
          # name contains "3"
          "3"
        ])

      row_count = SnippetHelpers.count_rows_from_output(output)

      assert row_count == 1
    end

    test "lists now rows when there is no snippet found through fuzzy search" do
      SnippetHelpers.add_multiple_test_snippets(3)

      {output, _} =
        GeneralHelpers.execute([
          "snippet",
          "search",
          "--name",
          "NOT_EXISTING_SNIPPET"
        ])

      row_count = SnippetHelpers.count_rows_from_output(output)

      assert row_count == 0
    end

    test "rejects to search when there are unallowed switches" do
      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "search",
          "--unallowed-switch",
          "Test snippet"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to search when '--name' switch is missing" do
      {output, exit_code} =
        GeneralHelpers.execute([
          "snippet",
          "add",
          "--code",
          "console.log()"
        ])

      assert exit_code == 0
      assert output =~ "❌"
    end
  end
end
