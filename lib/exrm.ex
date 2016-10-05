defmodule ReleaseManager.Plugin.Deb do
  require ReleaseManager.Config
  use ReleaseManager.Plugin

  def before_release(_), do: nil

  def after_release(%{deb: true} = _config) do
    case ExrmDeb.Config.build_config(:exrm) do
      {:ok, config} -> ExrmDeb.start_build(config)
      _             -> nil
    end
  end

  def after_release(_), do: nil
  def after_package(_), do: nil

  def after_cleanup(_args) do
    ExrmDeb.remove_deb_dir
  end

end
