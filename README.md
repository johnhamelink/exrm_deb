# Elixir Release Manager DEB generator

[![Coverage Status](https://coveralls.io/repos/github/johnhamelink/exrm_deb/badge.svg?branch=master)](https://coveralls.io/github/johnhamelink/exrm_deb?branch=master)
[![Build Status](https://travis-ci.org/johnhamelink/exrm_deb.svg?branch=master)](https://travis-ci.org/johnhamelink/exrm_deb)
[![Hex version](https://img.shields.io/hexpm/v/exrm_deb.svg "Hex version")](https://hex.pm/packages/exrm_deb)
[![Inline docs](http://inch-ci.org/github/johnhamelink/exrm_deb.svg)](http://inch-ci.org/github/johnhamelink/exrm_deb)

Adds simple [Debian Package][1] (DEB) generation to the exrm package manager.

## Functionality list

 1. [x] Able to build debian packages:
     1. [x] With changelog
     2. [x] With control file
 2. [x] Ability to add in pre/post install/remove scripts
 3. [x] Validates configuration before completing the build
 4. [x] Add ability for you to replace file templates with your own
 5. [x] [Distillery support](https://github.com/bitwalker/distillery)
 6. [ ] Automatically builds init scripts:
     1. [x] Upstart
     2. [x] Systemd
     3. [ ] SysV
 7. [ ] Handle functionality for Hot Upgrades
 8. [ ] Merge debian to-be-deployed files with your own structure

## External dependencies

Before using exrm-deb, you'll need the following commands installed and in your path:

 - `tar` (or `gtar` if you're on a mac - you can `brew install gnu-tar` if you don't already have it)
 - `ar`
 - `uname`

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

A list of configuration options you can add to `package/0`:

 - `licenses`
   - Array of strings
   - Can be something like `["Copyright <date> <company_name>"]` if you are building private packages.
 - `maintainers`
   - Array of Strings
   - Should be in the format `name <email>`
 - `external_dependencies`
   - Array of Strings
   - Should be in the format of `package-name (operator version_number)` where operator is either `<<`, `<=`, `=`, `>=`, or `>>` - [read more about this here.][4]
 - `maintainer_scripts`
   - A keyword list of Strings
   - The keyword should be one of: `:pre_install`, `:post_install`, `:pre_uninstall`, or `:post_uninstall`
   - The keyword should point to the path of a script you want to run at the moment in question.
 - `vendor`
   - String
   - The distribution vendor that's creating the debian package. I normally just put my name or company name.
 - `owner`
   - A keyword list of Strings
   - If set, requires both `user` and `group` keys to be set.
   - This is used when building the archive to set the correct user and group
   - Defaults to root for user & group.

## Usage

### Building Deb file

#### Exrm

You can build a deb at the same time as building a release by adding the --deb option to release.

```bash
mix release --deb
```

This task first constructs the release using exrm, then generates a deb file
for the release. The deb is built from scratch, retrieving default values such
as the name, version, etc using the `mix.exs` file.

The `_build/deb` directory tree, along with the rest of the release can be removed with `mix release.clean`

Please visit [exrm][3] for additional information.

#### Distillery

You can build a deb by adding `plugin ExrmDeb.Distillery` to your `rel/config.exs` file. With distillery, the name and version is taken from the `rel/config.exs` file as opposed to the `mix.exs` file.

### Customising deb config files

You can customise the debs that are being built by copying the template files used and modifying them:

```bash
mix release.deb.generate_templates
```

When you next run `mix release --deb`, your custom templates will be used instead of the defaults inside the plugin.

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
[4]:https://www.debian.org/doc/manuals/maint-guide/dreq.en.html#control
