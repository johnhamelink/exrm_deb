defmodule ExrmDeb.Mixfile do
  use Mix.Project

  def project do
    [app: :exrm_deb,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: "Create a deb for your elixir release with ease",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env),
     package: package]
  end

  def application, do: [applications: apps(Mix.env)]

  defp apps(:test) do
    apps(:all) ++ [:faker]
  end

  defp apps(_) do
    [:logger, :exrm, :timex]
  end

  defp deps(:test) do
    deps(:all) ++ [ {:faker, "~> 0.6"} ]
  end

  defp deps(_) do
    [
     {:exrm, "~> 1.0"},
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
