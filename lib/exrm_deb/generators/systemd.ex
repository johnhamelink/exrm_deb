defmodule ExrmDeb.Generators.Systemd do
  alias ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  def build(data_dir, config) do
    debug "Building Systemd Service File"

    systemd_script =
      [
        ExrmDeb.Utils.Config.project_dir,
        "templates", "init_scripts", "systemd.service.eex"
      ]
      |> Path.join
      |> EEx.eval_file([
        description: config.description,
        name: config.name,
        uid: config.owner[:user],
        gid: config.owner[:group]
      ])

    out_dir =
      [data_dir, "etc", "systemd", "system", "multi-user.target.wants"]
      |> Path.join

    :ok = File.mkdir_p(out_dir)

    :ok =
      [out_dir, config.sanitized_name <> ".service"]
      |> Path.join
      |> File.write(systemd_script)
  end

end
