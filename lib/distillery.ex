defmodule ExrmDeb.Distillery do
  use Mix.Releases.Plugin

  def before_assembly(release), do: release
  def after_assembly(release = %Release{}) do
    info "Building Deb Package"
    case ExrmDeb.Config.build_config(:distillery, release) do
      {:ok, config} ->
        ExrmDeb.start_build(config)
        release
      _ -> nil
    end
  end
  def after_assembly(release), do: release

  def before_package(release), do: release
  def after_package(release), do: release

  def before_release(release), do: release
  def after_release(release), do: release

  def after_cleanup(_args) do
    ExrmDeb.remove_deb_dir
    :ok
  end

end
