defmodule ExrmDeb.Control do
  alias ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  def build(deb_root, config) do
    control_dir = Path.join([deb_root, "control"])

    debug "Building debian control directory"
    :ok = File.mkdir_p(control_dir)

    build_control_file(config, control_dir)
    ExrmDeb.Utils.compress(control_dir, Path.join([control_dir, "..", "control.tar.gz"]))
    ExrmDeb.Utils.remove_tmp(control_dir)

    :ok
  end

  defp build_control_file(config, control_dir) do
    debug "Building Control file"

    out = """
    Package: #{config.sanitized_name}
    Version: #{config.version}
    License: #{config.licenses}
    Vendor: #{config.vendor}
    Architecture: #{config.arch}
    Maintainer: #{config.maintainers}
    Installed-Size: #{config.installed_size}
    Depends: #{config.external_dependencies}
    Priority: extra
    Section: misc
    Homepage: #{config.homepage}
    Description: #{config.description}
      #{config.version}
     .
      Automatically packaged by exrm_deb
    """

    :ok = File.write(Path.join([control_dir, "control"]), out)

    config
  end
end
