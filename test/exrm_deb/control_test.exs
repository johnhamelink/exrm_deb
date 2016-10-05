defmodule ExrmDebTest.ControlTest do
  use ExUnit.Case

  setup do
    {:ok, test_dir} =
      [File.cwd!, "test", "tmp_control"]
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

  test "Builds a control file to spec", meta do
    control_file = Path.join([meta.config.test_dir, "control"])

    # Build the control package
    assert :ok =
      ExrmDeb.Control.build(meta.config.test_dir, meta.config.metadata)
    assert true = File.exists?(control_file <> ".tar.gz")

    # Unpack it
    System.cmd(
      "tar",
      ["-zxvf", control_file <> ".tar.gz"],
      stderr_to_stdout: true)
    assert true = File.exists? control_file

    # Read the control file
    assert {:ok, file} = File.read(control_file)

    assert true = String.contains?(file, "Package:")
    assert true = String.contains?(file, meta.config.metadata.version)
  end

end
