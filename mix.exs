defmodule ExrmDeb.Mixfile do
  use Mix.Project

  def project do
    [app: :exrm_deb,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: "Create a deb for your elixir release with ease",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  def application do
    [applications: [:logger, :exrm, :timex]]
  end

  defp deps do
    [
     {:cf, "~> 0.2.1", override: true},   # remove this later (exrm acting up on elixir 1.2.1)
     {:erlware_commons,
       github: "erlware/erlware_commons",
       override: true},                   # remove this later (exrm acting up on elixir 1.2.1)
     {:exrm, github: "bitwalker/exrm",
       branch: "master", override: true}, # For making releases
     {:timex, "~> 1.0.1"}
    ]
  end

  def package do
    [
      external_dependencies: [],
      license_file: "LICENSE",
      files: [ "lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["John Hamelink <john@johnhamelink.com>"],
      licenses: ["MIT"],
      vendor: "John Hamelink",
      links:  %{
        "GitHub" => "https://github.com/johnhamelink/exrm_deb",
        "Docs" => "hexdocs.pm/exrm_deb",
        "Homepage" => "https://github.com/johnhamelink/exrm_deb"
      }
    ]
  end

end
