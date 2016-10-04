defmodule ExrmDeb.Distillery do
  use Mix.Releases.Plugin

  def before_assembly(release), do: release
  def after_assembly(release), do: release

  def before_package(release), do: release
  def after_package(release = %Release{}) do
    case ExrmDeb.Config.build_config do
      {:ok, config} -> ExrmDeb.start_build(config)
      _             -> nil
    end

    release
  end
  def after_package(release), do: release

  def before_release(release), do: release
  def after_release(release), do: release

  def after_cleanup(_args) do
    ExrmDeb.remove_deb_dir
    :ok
  end

end
