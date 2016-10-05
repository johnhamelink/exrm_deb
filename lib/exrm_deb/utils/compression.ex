defmodule ExrmDeb.Utils.Compression do
  @moduledoc ~S"""
  This module provides utilities related to file compression
  """
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]


  @doc """
  Decides which tar binary to use (in OSX, we need to use gtar)
  """
  def tar_cmd do
    case :os.type do
      {:unix, :darwin} -> "gtar"
      _ -> "tar"
    end
  end

  @doc """
  Gzip Compress a directory
  """
  def compress(dir, outfile, opts \\ []) do
    debug "Compressing #{dir} -> #{outfile}"

    opts =
      opts
      |> Enum.flat_map(fn(option) ->
      case option do
        {:owner, value} -> ["--owner", value[:user], "--group", value[:group]]
        {key, value} -> ["--#{Atom.to_string(key)}", value]
        _ -> [option]
      end
    end)

    cmd_opts = opts ++ ["-acf", outfile, "."]

    {_ignore, 0} = System.cmd(
      tar_cmd,
      cmd_opts,
      cd: dir,
      stderr_to_stdout: true,
      env: [{"GZIP", "-9"}]
    )
  end

end
