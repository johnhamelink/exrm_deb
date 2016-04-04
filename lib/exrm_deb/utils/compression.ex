defmodule ExrmDeb.Utils.Compression do
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  @doc """
  Gzip Compress a directory
  """
  def compress(dir, outfile, opts \\ []) do
    debug "Compressing #{dir} -> #{outfile}"

    # generate file list based on given directory
    file_list = dir
                |> ExrmDeb.Utils.File.ls_r
                |> Enum.map(&({'#{&1}','#{Path.join([dir, &1])}'}))

    # always use an absolute path for destination file
    destfile =  outfile
                |> Path.type
                |> case do
                  :relative -> Path.join([dir, outfile])
                  _         -> outfile
                end
                |> Path.expand

    # create tmp tar file
    :ok = :erl_tar.create(
      '#{destfile}.tmp',
      file_list,
      [:compressed]
    )

    opts
    |> Keyword.get(:fakeroot, false)
    |> if do
        # set all files in tar to uid/gid 0/0
        {:ok, gzip} = :swab.sync [convert: :gunzip, tar: :fakeroot, convert: :gzip], File.read!(destfile <> ".tmp")

        # create final tar file
        :ok = File.write!(destfile, gzip)

        :ok = File.rm!(destfile <> ".tmp")
      else
        # no fakeroot, just rename
        File.rename destfile <> ".tmp", destfile
      end
  end

end
