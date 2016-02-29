defmodule ExrmDeb.Utils.Config do
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1]

  @doc """
  Use uname to detect the architecture we're currently building for
  """
  def detect_arch do
    {arch, 0} = System.cmd("uname", ["-m"])
    arch = String.replace(arch, "\n", "")
    case arch do
      "x86_64" -> "amd64"
      "noarch" -> "all"
      _ -> arch
    end
  end

  @doc """
  Produce a config map which is used throughout
  ExrmDeb.
  """
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

  @doc """
  Sanitize certain elements so that they are (for example) filesystem safe.
  """
  def sanitize_config(config = %{}) do
    sanitized_name =
      config.name
      |> String.downcase
      |> String.replace(~r([^a-z\-\+\.]), "")

    Map.put(config, :sanitized_name, sanitized_name)
  end

  @doc """
  Retrieve the Application root, which is used when referring to relative files
  in the library (such as templates)
  """
  def project_dir do
    Application.get_env(:exrm_deb, :root)
  end
end
