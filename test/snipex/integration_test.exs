defmodule Snipex.IntegrationTest do
  use ExUnit.Case
  use Snipex.StorageCase, async: true

  @executable Path.expand("../../snipex", __DIR__)
  @tmp_path Path.expand("tmp/test_data")

  setup do
    System.cmd(@executable, ["init"], env: [{"SNIPEX_STORAGE_PATH", @tmp_path}])
    :ok
  end

  describe "snippet add" do
    test "adds a new snippet" do
      {output, exit_code} =
        System.cmd(
          @executable,
          [
            "snippet",
            "add",
            "--name",
            "Test snippet",
            "--code",
            "IO.puts(\"Hello\")"
          ],
          env: [{"SNIPEX_STORAGE_PATH", @tmp_path}]
        )

      assert exit_code == 0
      assert output =~ "✅"
    end

    test "rejects to add a new snippet when there is one snippet already added with the same name" do
      name = "IO.puts(\"Hello\")"

      {_, _} =
        System.cmd(
          @executable,
          [
            "snippet",
            "add",
            "--name",
            name,
            "--code",
            "IO.puts(\"Hello\")"
          ],
          env: [{"SNIPEX_STORAGE_PATH", @tmp_path}]
        )

      {output, exit_code} =
        System.cmd(
          @executable,
          [
            "snippet",
            "add",
            "--name",
            name,
            "--code",
            "IO.puts(\"Hello\")"
          ],
          env: [{"SNIPEX_STORAGE_PATH", @tmp_path}]
        )

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to add a new snippet when there are unallowed switches" do
      {output, exit_code} =
        System.cmd(
          @executable,
          [
            "snippet",
            "add",
            "--unallowed-switch",
            "Test snippet"
          ],
          env: [{"SNIPEX_STORAGE_PATH", @tmp_path}]
        )

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to add a new snippet when '--code' switch is missing" do
      {output, exit_code} =
        System.cmd(
          @executable,
          [
            "snippet",
            "add",
            "--name",
            "Test snippet"
          ],
          env: [{"SNIPEX_STORAGE_PATH", @tmp_path}]
        )

      assert exit_code == 0
      assert output =~ "❌"
    end

    test "rejects to add a new snippet when '--name' switch is missing" do
      {output, exit_code} =
        System.cmd(
          @executable,
          [
            "snippet",
            "add",
            "--code",
            "IO.puts(\"Hello\")"
          ],
          env: [{"SNIPEX_STORAGE_PATH", @tmp_path}]
        )

      assert exit_code == 0
      assert output =~ "❌"
    end
  end
end
