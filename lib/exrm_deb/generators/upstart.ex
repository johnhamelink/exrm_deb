defmodule ExrmDeb.Generators.Upstart do
  alias ReleaseManager.Utils.Logger
  alias ExrmDeb.Generators.TemplateFinder
  import Logger, only: [debug: 1]

  def build(data_dir, config) do
    debug "Building Upstart file"

    upstart_script =
      TemplateFinder.retrieve(["init_scripts", "upstart.conf.eex"])
      |> EEx.eval_file([
          description: config.description,
          name: config.name,
          uid: config.owner[:user],
          gid: config.owner[:group]
      ])

    out_dir =
      [data_dir, "etc", "init"]
      |> Path.join

    :ok = File.mkdir_p(out_dir)

    :ok =
      [out_dir, config.sanitized_name <> ".conf"]
      |> Path.join
      |> File.write(upstart_script)
  end

end
