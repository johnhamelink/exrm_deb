defmodule ExrmDebTest.FileTest do
  use ExUnit.Case

  setup do
    {:ok, test_dir} =
      [File.cwd!, "tmp_file"]
      |> Path.join
      |> TestHelper.tmp_directory

    on_exit fn ->
      :ok =
        [test_dir, ".."]
        |> Path.join
        |> Path.wildcard
        |> File.cd

      {:ok, _} = File.rm_rf(test_dir)
    end

    {:ok, config: %{ test_dir: test_dir }}
  end

  test "Removes FS metadata", meta do

    # Make a directory for our stuff to go in
    :ok =
      [meta.config.test_dir, "foo"]
      |> Path.join
      |> File.mkdir

    # Make some junk files
    File.write(Path.join(meta.config.test_dir, "foo/.DS_Store"), "lorem")
    File.write(Path.join(meta.config.test_dir, "foo/thumbs.db"), "ipsum")

    # Attempt to remove them
    ExrmDeb.Utils.File.remove_fs_metadata(meta.config.test_dir)

    # Check they've been removed
    assert File.exists?(Path.join(meta.config.test_dir, ".DS_Store")) == false
    assert File.exists?(Path.join(meta.config.test_dir, "thumbs.db")) == false

  end

end
