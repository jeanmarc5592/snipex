defmodule Snipex.StorageCase do
  use ExUnit.CaseTemplate
  import ExUnit.CaptureIO

  using do
    quote do
      @tmp_path "tmp/test_data"
    end
  end

  # Runs before every test
  setup do
    File.rm_rf!("tmp/test_data")
    File.mkdir_p!("tmp/test_data")
    System.put_env("SNIPEX_STORAGE_DIR", Path.expand("tmp/test_data"))

    capture_io(fn ->
      Snipex.Storage.init()
    end)

    :ok
  end
end
