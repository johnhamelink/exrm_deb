defmodule ReleaseManager.Plugin.Deb do
  require ReleaseManager.Config
  use ReleaseManager.Plugin
  alias ExrmDeb.{Control, Data, Deb}

  def before_release(_), do: nil

  def after_release(%{deb: true} = _config) do
    case ExrmDeb.Config.build_config do
      {:ok, config} -> start_build(config)
      _             -> nil
    end
  end

  def after_release(_), do: nil
  def after_package(_), do: nil

  def after_cleanup(_args) do
    remove_deb_dir
  end

  defp start_build(config) do
    remove_deb_dir
    deb_root = initialize_dir

    {:ok, config} = Data.build(deb_root, config)
    :ok = Control.build(deb_root, config)
    :ok = Deb.build(deb_root, config)

    info("A debian package has successfully been created. You can find it in the ./rel directory")
  end

  defp remove_deb_dir do
    Path.join([Mix.Project.build_path, "deb"])
    |> File.rmdir
  end

  defp initialize_dir do
    deb_root = Path.join([Mix.Project.build_path, "deb"])

    debug("Building base debian directory")
    :ok = File.mkdir_p(deb_root)

    debug("Adding debian-binary file")
    :ok = File.write(Path.join(deb_root, "debian-binary"), "2.0\n")

    deb_root
  end

end
