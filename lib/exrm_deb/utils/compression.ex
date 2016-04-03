defmodule ExrmDeb.Utils.Compression do
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  @doc """
  Gzip Compress a directory
  """
  def compress(dir, outfile) do
    debug "Compressing #{dir} -> #{outfile}"

    # generate file list based on given directory
    file_list = dir
                |> File.ls!
                |> Enum.map(&({'#{&1}','#{Path.join([dir, &1])}'}))

    # always use an absolute path for destination file
    destfile =  outfile
                |> Path.type
                |> case do
                  :relative -> Path.join([dir, outfile])
                  _         -> outfile
                end
                |> Path.expand

    :ok = :erl_tar.create(
      '#{destfile}',
      file_list,
      [:compressed]
    )

  end

end
