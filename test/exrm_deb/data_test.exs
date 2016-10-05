defmodule ExrmDebTest.DataTest do
  use ExUnit.Case

  setup do
    {:ok, test_dir} =
      [File.cwd!, "tmp_data"]
      |> Path.join
      |> TestHelper.tmp_directory

    File.cd(test_dir)

    on_exit fn ->
      :ok =
        [test_dir, ".."]
        |> Path.join
        |> Path.wildcard
        |> File.cd

      {:ok, _} = File.rm_rf(test_dir)
    end

    {:ok, config: %{
        test_dir: test_dir,
        metadata: TestHelper.metadata
    }}
  end

  test "Builds data directory correctly", meta do
    data_pkg = Path.join([meta.config.test_dir, "data.tar.gz"])

    app_path =
      Path.join([meta.config.test_dir, "rel", meta.config.metadata.name])
    src_test_file = Path.join(app_path, "test_file")

    dest_test_file = Path.join([
      meta.config.test_dir,
      "opt",
      meta.config.metadata.name,
      "test_file"
    ])

    changelog = Path.join([
      meta.config.test_dir,
      "usr", "share", "doc",
      meta.config.metadata.sanitized_name,
      "changelog.gz"
    ])

    # Make sample data
    :ok = File.mkdir_p(app_path)
    :ok = File.write(src_test_file, "Lorem Ipsum")

    # Build the data package
    assert {:ok, _} =
      ExrmDeb.Data.build(meta.config.test_dir, meta.config.metadata)
    assert true     = File.exists?(data_pkg)

    # Unpack it
    System.cmd(
      "tar",
      ["-zxvf", data_pkg],
      stderr_to_stdout: true)
    assert true = File.exists? dest_test_file
    assert true = File.exists? changelog
  end

end
