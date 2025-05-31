defmodule Snipex.Helpers.General do
  @executable Path.expand("../../../snipex", __DIR__)
  @tmp_path Path.expand("tmp/test_data")
  @env {"SNIPEX_STORAGE_PATH", @tmp_path}

  def execute(command) do
    System.cmd(@executable, command, env: [@env])
  end
end
