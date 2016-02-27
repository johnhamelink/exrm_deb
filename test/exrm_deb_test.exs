defmodule ExrmDebTest do
  use ExUnit.Case

  setup do
    test_dir = Path.join([File.cwd!, "test", "tmp"])
    {:ok, _} = File.rm_rf(test_dir)
    :ok = File.mkdir_p(test_dir)

    metadata = %{
      name:                  Faker.App.name,
      version:               Faker.App.version,
      licenses:              ["MIT", "GPL2"],
      vendor:                Faker.Company.name,
      arch:                  "amd64",
      maintainers:           ["#{Faker.Name.name} <#{Faker.Internet.email}>"],
      installed_size:        9999,
      external_dependencies: ["firefox"],
      homepage:              Faker.Internet.url,
      description:           Faker.Lorem.paragraph(1..5)
    }
    |> ExrmDeb.Utils.sanitize_config

    ReleaseManager.Utils.Logger.start_link

    :ok = File.cd(test_dir)

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
        metadata: metadata
    }}
  end

  test "Builds a control file to spec", meta do
    control_file = Path.join([meta.config.test_dir, "control"])

    # Build the control package
    assert :ok = ExrmDeb.Control.build(meta.config.test_dir, meta.config.metadata)
    assert true = File.exists?(control_file <> ".tar.gz")

    # Unpack it
    System.cmd("tar", ["-zxvf", control_file <> ".tar.gz"])
    assert true = File.exists? control_file

    # Read the control file
    assert {:ok, file} = File.read(control_file)

    assert true = String.contains?(file, "Package:")
    assert true = String.contains?(file, meta.config.metadata.version)
  end

end
