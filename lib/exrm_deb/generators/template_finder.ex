defmodule ExrmDeb.Generators.TemplateFinder do
  alias ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1, info: 1]

  def retrieve(pathname) do
    path = user_provided_path(pathname)
    case File.exists?(path) do
      true  ->
        info "Using user-provided file: #{path |> Path.basename}"
        path
      false ->
        debug "Using default file: #{path |> Path.basename} - didn't find user-provided one"
        default_path(pathname)
    end
  end

  defp user_provided_path(pathname) do
    [
      ReleaseManager.Utils.rel_dest_path,
      "exrm_deb", "templates", pathname
    ]
    |> List.flatten
    |> Path.join
  end

  defp default_path(pathname) do
    [
      ExrmDeb.Utils.Config.root,
      "templates", pathname
    ]
    |> List.flatten
    |> Path.join
  end

end
