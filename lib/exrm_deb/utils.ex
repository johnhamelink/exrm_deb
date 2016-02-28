defmodule ExrmDeb.Utils do
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  @doc """
  Retrieves all the files within a directory, retrieves the size of all these
  files, then adds them all together.
  """
  def get_dir_size(dir) do
    {_parts, size} =
      [dir, "**"]
      |> Path.join
      |> Path.wildcard
      |> Enum.map_reduce(0, fn(file, acc) ->
        size = File.stat!(file).size
        {size, size + acc}
      end)
    size
  end

  def tar_cmd do
    case :os.type do
      {:unix, :darwin} -> "gtar"
      _ -> "tar"
    end
  end

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

  def remove_tmp(dir) do
    debug "Removing #{dir}"
    {:ok, _files} = File.rm_rf(dir)
  end

  def detect_arch do
    {arch, 0} = System.cmd("uname", ["-m"])
    arch = String.replace(arch, "\n", "")
    case arch do
      "x86_64" -> "amd64"
      "noarch" -> "all"
      _ -> arch
    end
  end

  def build_config(config = %{}) do
    mix_config = Mix.Project.config

    # TODO: Remove defaults & add
    # config checker before doing anything.

    %{
      licenses:              Enum.join((mix_config[:package][:licenses] || []), ", "),
      maintainers:           Enum.join(mix_config[:package][:maintainers], ", "),
      external_dependencies: Enum.join((mix_config[:package][:external_dependencies] || []), ", "),
      maintainer_scripts:    (mix_config[:package][:maintainer_scripts] || []),
      init_scripts:          [],
      homepage:              Map.fetch!(mix_config[:package][:links], "Homepage"),
      description:           mix_config[:description],
      vendor:                mix_config[:package][:vendor],
      arch:                  detect_arch,
      owner:                 (mix_config[:package][:owner] || [user: "root", group: "root"])
    }
    |> Map.merge(config)
    |> sanitize_config
  end

  def sanitize_config(config = %{}) do
    sanitized_name =
      config.name
      |> String.downcase
      |> String.replace(~r([^a-z\-\+\.]), "")

    Map.put(config, :sanitized_name, sanitized_name)
  end

  def project_dir do
    Application.get_env(:exrm_deb, :root)
  end

end
