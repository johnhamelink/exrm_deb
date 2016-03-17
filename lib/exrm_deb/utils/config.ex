defmodule ExrmDeb.Utils.Config do

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
  def root do
    Mix.Project.deps_paths
    |> Map.fetch(:exrm_deb)
    |> case do
         {:ok, path} -> path
         :error      -> # We're trying to build ourself!?
           Application.get_env(:exrm_deb, :root)
    end
  end

end
