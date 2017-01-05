defmodule ExrmDeb.Data do
  @moduledoc ~S"""
  This module houses the logic required to build the data payload portion of the
  debian package.
  """
  alias ReleaseManager.Utils.Logger
  alias ExrmDeb.Utils.Compression
  alias ExrmDeb.Generators.{Changelog, Upstart, Systemd}
  alias Mix.Project
  import Logger, only: [debug: 1]

  def build(dir, config) do
    data_dir = make_data_dir(dir, config)
    copy_release(data_dir, config)
    remove_targz_file(data_dir, config)
    ExrmDeb.Utils.File.remove_fs_metadata(data_dir)
    Changelog.build(data_dir, config)
    Upstart.build(data_dir, config)
    Systemd.build(data_dir, config)

    config = Map.put_new(
      config,
      :installed_size,
      ExrmDeb.Utils.File.get_dir_size(data_dir)
    )

    Compression.compress(
      data_dir,
      Path.join([data_dir, "..", "data.tar.gz"]),
      owner: config.owner
    )
    ExrmDeb.Utils.File.remove_tmp(data_dir)

    {:ok, config}
  end


  # We don't use/need the .tar.gz file built be exrm, so
  # remove it from the data dir to reduce filesize.
  defp remove_targz_file(data_dir, config) do
    [data_dir, "opt", config.name, "#{config.name}-#{config.version}.tar.gz"]
    |> Path.join
    |> File.rm
  end

  defp make_data_dir(dir, config) do
    debug("Building debian data directory")
    data_dir = Path.join([dir, "data"])
    :ok = File.mkdir_p(data_dir)
    :ok = File.mkdir_p(Path.join([data_dir, "opt", config.name]))

    data_dir
  end

  defp copy_release(data_dir, config) do
    dest = Path.join([data_dir, "opt", config.name])
    src = Path.join([Project.build_path, "rel", config.name])

    debug("Copying #{src} into #{dest} directory")
    {:ok, _} = File.cp_r(src, dest)

    dest
  end
end
