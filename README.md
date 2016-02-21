# Elixir Release Manager DEB generator

Adds simple [Debian Package][1] (DEB) generation to the exrm package manager.

## Configuration

Exrm-deb relies on the following data in the `mix.exs` file being set:

```diff
defmodule Testapp.Mixfile do
   use Mix.Project

   def project do
      [app: :testapp,
      version: "0.0.1",
      elixir: "~> 1.0",
+     description: "Create a deb for your elixir release with ease",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
-     deps: deps]
+     deps: deps,
+     package: package]
   end
```

The `package` function must be set as per the [hex guidelines][2], but with some extra lines:

```diff
def package do
   [
+     external_dependencies: [],
+     license_file: "LICENSE",
      files: [ "lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["John Hamelink <john@example.com>"],
      licenses: ["MIT"],
      vendor: "John Hamelink",
      links:  %{
        "GitHub" => "https://github.com/johnhamelink/testapp",
        "Docs" => "hexdocs.pm/testapp",
+       "Homepage" => "https://github.com/johnhamelink/testapp"
      }
   ]
end
```

## Usage

You can build a deb at the same time as building a release by adding the --deb option to release.

```bash
mix release --deb
```

This task first constructs the release using exrm, then generates a deb file
for the release. The deb is built from scratch, retrieving default values such
as the name, version, etc using the `mix.exs` file.

The `_build/deb` directory tree, along with the rest of the release can be removed with `mix release.clean`

Please visit [exrm][3] for additional information.

## Installation

The package can be installed as:

  1. Add exrm_deb to your list of dependencies in `mix.exs`:

        def deps do
          [{:exrm_deb, "~> 0.0.1"}]
        end

  2. Ensure exrm_deb is started before your application:

        def application do
          [applications: [:exrm_deb]]
        end


[1]:https://en.wikipedia.org/wiki/Deb_(file_format)
[2]:https://hex.pm/docs/publish
[3]:https://github.com/bitwalker/exrm
