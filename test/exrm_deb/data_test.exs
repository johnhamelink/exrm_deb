defmodule ExrmDebTest.DataTest do
  use ExUnit.Case

  setup do
    test_dir = Path.join([File.cwd!, "tmp_data"])
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
      description:           Faker.Lorem.paragraph(1..5),
      maintainer_scripts:    [],
      owner:                 [user: "root", group: "root"]
    }
    |> ExrmDeb.Utils.sanitize_config

    # Required to stop Logger.debug from returning
    # GenServer errors.
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

  test "Builds data directory correctly", meta do
    data_pkg = Path.join([meta.config.test_dir, "data.tar.gz"])

    app_path = Path.join([meta.config.test_dir, "rel", meta.config.metadata.name])
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
    assert {:ok, _} = ExrmDeb.Data.build(meta.config.test_dir, meta.config.metadata)
    assert true     = File.exists?(data_pkg)

    # Unpack it
    System.cmd("tar", ["-zxvf", data_pkg], stderr_to_stdout: true)
    assert true = File.exists? dest_test_file
    assert true = File.exists? changelog
  end

end
