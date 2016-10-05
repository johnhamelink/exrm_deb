ExUnit.start()

defmodule TestHelper do

  def tmp_directory(path) do
    {:ok, _} = File.rm_rf(path)
    :ok = File.mkdir_p(path)
    {:ok, path}
  end

  def metadata do
    %{
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
    } |> ExrmDeb.Utils.Config.sanitize_config
  end

end
