defmodule ExrmDebTest do
  use ExUnit.Case
  alias ReleaseManager.Config
  alias ReleaseManager.Utils
  alias ReleaseManager.Plugin.Deb

  setup do
    File.rm_rf(Path.join([File.cwd!, "_build", "deb"])
    config = %Config{name: "test", version: "0.0.1"}
    {:ok, config: Map.merge(config, %{dep: true, build_arch: "x86_64"})}
  end

  def create_deb_build(config) do
    build_arch = Deb.get_config_item config, :build_arch, "x86_64"
    rpm_file = Deb.deb_file_name(config.name, config.version, build_arch)
    IO.puts deb_file
  end

  test "creates the control directories", meta do
    Deb.after_release(meta[:config])
  end

end
