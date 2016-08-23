defmodule ExrmDeb.Mixfile do
  use Mix.Project

  def project do
    [app: :exrm_deb,
     version: "0.0.6",
     elixir: "~> 1.0",
     description: "Create a deb for your elixir release with ease",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     package: package]
  end

  def application, do: [applications: apps(Mix.env)]

  defp apps(:test) do
    apps(:all) ++ [:faker]
  end

  defp apps(:dev) do
    apps(:all) ++ [:ex_doc, :earmark]
  end

  defp apps(_) do
    [:logger, :exrm, :timex, :vex]
  end

  defp deps(:test) do
    deps(:all) ++ [
      {:faker, "~> 0.6", only: :test},
      {:excoveralls, "~> 0.4", only: :test},
    ]
  end

  defp deps(:docs) do
    deps(:all) ++ [
      {:inch_ex, "~> 0.5", only: :docs}
    ]
  end

  defp deps(:dev) do
    deps(:all) ++ [
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, "~> 0.2", only: :dev}
    ]
  end

  defp deps(_) do
    [
     {:exrm, "~> 1.0"},
     {:timex, "~> 2.1"},
     {:vex, "~> 0.5"}
    ]
  end

  def package do
    [
      maintainer_scripts: [
        pre_install: "config/deb/pre_install.sh"
      ],
      external_dependencies: [],
      license_file: "LICENSE",
      files: [ "lib", "mix.exs", "README*", "LICENSE", "templates"],
      maintainers: ["John Hamelink <john@johnhamelink.com>"],
      licenses: ["MIT"],
      vendor: "John Hamelink",
      links:  %{
        "GitHub" => "https://github.com/johnhamelink/exrm_deb",
        "Docs" => "https://hexdocs.pm/exrm_deb",
        "Homepage" => "https://github.com/johnhamelink/exrm_deb"
      }
    ]
  end

end
