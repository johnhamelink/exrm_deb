defmodule ExrmDeb.Data do
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  def build(dir, config) do

    # TODO:
    # - Add init script
    # - Add ability to create pre-inst / post-inst hooks
    # - Add ability to add conform config as a config file (how?).

    data_dir = make_data_dir(dir, config)
    copy_release(data_dir, config)
    remove_targz_file(data_dir, config)
    remove_fs_metadata(data_dir)
    add_changelog(data_dir, config)

    config = Map.put_new(
      config,
      :installed_size,
      ExrmDeb.Utils.get_dir_size(data_dir)
    )

    ExrmDeb.Utils.compress(
      data_dir,
      Path.join([data_dir, "..", "data.tar.gz"]),
      owner: config.owner
    )
    ExrmDeb.Utils.remove_tmp(data_dir)

    {:ok, config}
  end

  defp remove_fs_metadata(data_dir) do
    debug "Removing Filesystem metadata"
    Path.join([data_dir, "**"])
    |> remove_all_files_by_name(".DS_Store")
    |> remove_all_files_by_name("thumbs.db")
  end

  defp remove_all_files_by_name(root, name) do
    [root, name]
    |> Path.join
    |> Path.wildcard
    |> Enum.each(&(File.rm(&1)))

    root
  end

  # We don't use/need the .tar.gz file built be exrm, so
  # remove it from the data dir to reduce filesize.
  defp remove_targz_file(data_dir, config) do
    :ok =
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
    src = Path.join(ReleaseManager.Utils.rel_dest_path, config.name)

    debug("Copying #{src} into #{dest} directory")
    {:ok, _} = File.cp_r(src, dest)

    dest
  end

  defp add_changelog(data_dir, config) do

    {:ok, time} =
      Timex.Date.universal
      |> Timex.DateFormat.format("%a, %d %b %Y %H:%M:%S GMT", :strftime)

    out = """
    #{config.sanitized_name} (#{config.version}) whatever; urgency=medium

      * Package created by exrm_deb

     -- #{config.maintainers} #{time}
    """

    doc_dir =
      [data_dir, "usr", "share", "doc", config.sanitized_name]
      |> Path.join

    :ok = File.mkdir_p(doc_dir)

    :ok =
      [doc_dir, "changelog"]
      |> Path.join
      |> File.write(out)

    ExrmDeb.Utils.compress(doc_dir, "../changelog.gz")

    Path.join([doc_dir, "changelog"])
    |> File.rm

    [doc_dir, "../changelog.gz"]
    |> Path.join
    |> File.rename(Path.join([doc_dir, "changelog.gz"]))

  end
end
