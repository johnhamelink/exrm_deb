defmodule ExrmDebTest.CompressionTest do
  use ExUnit.Case

  setup do
    {:ok, test_dir} =
      [File.cwd!, "tmp_compression", "compress_me"]
      |> Path.join
      |> TestHelper.tmp_directory

    on_exit fn ->
      :ok =
        [test_dir, "..", ".."]
        |> Path.join
        |> Path.expand
        |> File.cd

      {:ok, _} =
        [test_dir, ".."]
        |> Path.join
        |> Path.expand
        |> File.rm_rf
    end

    {:ok, config: %{ test_dir: test_dir }}
  end

  test "Compresses directories correctly", meta do

    ExrmDeb.Utils.Compression.compress(
      meta.config.test_dir,
      [meta.config.test_dir, "..", "out.tar.gz"]
      |> Path.join
      |> Path.expand
    )

    assert true =
      [meta.config.test_dir, "..", "out.tar.gz"]
      |> Path.join
      |> File.exists?
  end

end
