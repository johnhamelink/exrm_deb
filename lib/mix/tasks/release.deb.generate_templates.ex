defmodule Mix.Tasks.Release.Deb.GenerateTemplates do
  @moduledoc """
  Copy Template files into project source directory so that
  users can modify them for their own purposes.

  ## Examples
  mix release.deb.generate_templates
  """

  @shortdoc "Copy exrm_deb template files into ./rel/exrm_deb/templates"

  use Mix.Task
  require Logger
  alias ExrmDeb.Utils.Config, as: ConfigUtil
  alias ReleaseManager.Utils

  def run(_args) do
    make_dest_dir
    copy_templates
  end

  def copy_templates(dest \\ destination_dir) do
    Logger.info "Copying templates to ./rel/exrm_deb/templates"
    {:ok, _} =
      [ConfigUtil.root, "templates"]
      |> Path.join
      |> File.cp_r(dest, fn(_source, destination) ->
        IO.gets("Overwriting #{destination |> Path.basename }." <>
                "Type y to confirm: ") == "y\n"
      end)
  end

  defp make_dest_dir do
    Logger.info "Making ./rel/exrm_deb/templates directory"
    :ok =
      destination_dir
      |> File.mkdir_p
  end

  defp destination_dir do
    [Utils.rel_dest_path, "exrm_deb", "templates"]
    |> Path.join
  end

end
