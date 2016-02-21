# Elixir Release Manager DEB generator

Adds simple [Debian Package][1] (DEB) generation to the exrm package manager.

## Usage

You can build a db at the same time as building a release by adding the --deb option to release

```bash
mix release --deb
```

This task first constructs the release using exrm, then generates a deb file
for the release. The deb is built from scratch, retrieving default values such
as the name, version, etc using the `mix.exs` file.

The `_build/deb` directory tree, along with the rest of the release can be removed with `mix release.clean`

Please visit [exrm][2] for additional information.

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
[2]:https://github.com/bitwalker/exrm
