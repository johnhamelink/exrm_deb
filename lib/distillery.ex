defmodule ExrmDeb.Distillery do
  @moduledoc ~S"""
  This module provides integration with
  [Distillery](https://github.com/bitwalker/distillery)'s plugin system.
  """
  use Mix.Releases.Plugin

  def before_assembly(release, _options), do: release
  def after_assembly(release = %Release{}, _options) do
    info "Building Deb Package"
    case ExrmDeb.Config.build_config(:distillery, release) do
      {:ok, config} ->
        ExrmDeb.start_build(config)
        release
      _ -> nil
    end
  end
  def after_assembly(release, _options), do: release

  def before_package(release, _options), do: release
  def after_package(release, _options), do: release

  def before_release(release, _options), do: release
  def after_release(release, _options), do: release

  def after_cleanup(_args, _options) do
    ExrmDeb.remove_deb_dir
    :ok
  end

end
