defmodule ExrmDeb.Control do
  alias ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  # - Add ability to create pre-inst / post-inst hooks [WIP]
  def build(deb_root, config) do
    control_dir = Path.join([deb_root, "control"])

    debug "Building debian control directory"
    :ok = File.mkdir_p(control_dir)

    build_control_file(config, control_dir)
    add_custom_hooks(config, control_dir)
    ExrmDeb.Utils.compress(control_dir, Path.join([control_dir, "..", "control.tar.gz"]))
    ExrmDeb.Utils.remove_tmp(control_dir)

    :ok
  end

  defp add_custom_hooks(config, control_dir) do
    debug "Adding in custom hooks"
    for {type, path} <- config.maintainer_scripts do
      script =
        [File.cwd!, path]
        |> Path.join

      true = File.exists?(script)
      filename =
        case type do
          :pre_install    -> "preinst"
          :post_install   -> "postinst"
          :pre_uninstall  -> "prerm"
          :post_uninstall -> "postrm"
          _               -> Atom.to_string(type)
        end

      filename =
        [control_dir, filename]
        |> Path.join

      debug "Copying #{Atom.to_string(type)} file to #{filename}"
      File.cp(script, filename)
    end
  end

  defp build_control_file(config, control_dir) do
    debug "Building Control file"

    out =
      [
        ExrmDeb.Utils.project_dir,
        "templates", "control.eex"
      ]
      |> Path.join
      |> EEx.eval_file([
        description: config.description,
        sanitized_name: config.sanitized_name,
        version: config.version,
        licenses: config.licenses,
        vendor: config.vendor,
        arch: config.arch,
        maintainers: config.maintainers,
        installed_size: config.installed_size,
        external_dependencies: config.external_dependencies,
        homepage: config.homepage
      ])

    :ok = File.write(Path.join([control_dir, "control"]), out)

    config
  end
end
