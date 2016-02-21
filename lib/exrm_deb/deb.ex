defmodule ExrmDeb.Deb do
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  def build(dir, config) do
    debug "Building deb file"

    out = Path.join([
      ReleaseManager.Utils.rel_dest_path,
      "#{config.sanitized_name}-#{config.version}.deb"
    ])

    args = [
      "-qc",
      out,
      Path.join([dir, "debian-binary"]),
      Path.join([dir, "control.tar.gz"]),
      Path.join([dir, "data.tar.gz"]),
    ]

    {_response, 0} = System.cmd("ar", args)

    :ok
  end

end
