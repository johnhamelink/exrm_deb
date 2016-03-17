defmodule ExrmDeb.Config do
  defstruct name: nil, version: nil, licenses: nil, maintainers: nil,
            external_dependencies: nil, maintainer_scripts: [],
            homepage: nil, description: nil, vendor: nil,
            arch: nil, owner: [user: "root", group: "root"]

  use Vex.Struct
  alias  ReleaseManager.Utils.Logger
  import Logger, only: [debug: 1, error: 1]

  # This version number format should be able to handle regular version
  # numbers as well as alpha/beta versions
  @version_number_format ~r/([0-9]+)\.([0-9]+)\.([0-9]+)\-?([a-z[0-9]*)/

  validates :name, presence: true
  validates :version, presence: true, format: @version_number_format
  validates :arch, presence: true
  validates :vendor, presence: true
  validates :description, presence: true
  validates :homepage, presence: true
  validates [:owner, :user], presence: true
  validates [:owner, :group], presence: true
  validates :licenses, presence: true
  validates :maintainers, presence: true

  def build_config(old_config = %{} \\ %{}) do
    base_config =
      [
        {:name, Atom.to_string(Mix.Project.config[:app])},
        {:version,Mix.Project.config[:version]},
        {:description, Mix.Project.config[:description]},
        {:arch, ExrmDeb.Utils.Config.detect_arch}
      ] ++ config_from_package(Mix.Project.config[:package])
      |> Enum.dedup
      |> Enum.reject(&(is_nil(&1)))
      |> Enum.into(%{})

    ExrmDeb.Config
    |> struct(Map.merge(base_config, old_config))
    |> ExrmDeb.Utils.Config.sanitize_config
    |> check_valid
  end

  defp config_from_package(nil) do
    """
    Error: You haven't defined any 'package' data in mix.exs.
    Check the configuration section of the github repository to
    see how to add this in.
    """
    |> String.replace("\n", " ")
    |> throw
  end
  defp config_from_package(value) when is_list(value) do
    Enum.map(value, fn({key, value}) -> handle_config(key, value) end)
    |> Enum.dedup
    |> Enum.reject(&(is_nil(&1)))
  end

  defp handle_config(:licenses, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> {:licenses, Enum.join(value, ", ")}
    end
  end
  defp handle_config(:maintainers, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> {:maintainers, Enum.join(value, ", ")}
    end
  end
  defp handle_config(:external_dependencies, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> {:external_dependenices, Enum.join(value, ", ")}
    end
  end
  defp handle_config(:maintainer_scripts, value) when is_list(value) do
    case Enum.count(value) do
      0 -> nil
      _ -> {:maintainer_scripts, value}
    end
  end
  defp handle_config(:links, value) when is_map(value) do
    case Map.fetch!(value, "Homepage") do
      nil -> nil
      homepage -> {:homepage, homepage}
    end
  end
  defp handle_config(:vendor, value) when is_binary(value) do
    case String.length(value) do
      0 -> nil
      _ -> {:vendor, value}
    end
  end
  defp handle_config(_, _), do: nil

  defp check_valid(config = %ExrmDeb.Config{}) do
    # Use Vex to validate whether the config is valid. If not,
    # then raise an error with a list of config errors
    if Vex.valid?(config) == false do
      error "The configuration is invalid!"
      for err = {:error, _field, _type, _msg} <- Vex.errors(config) do
        print_validation_error(err)
      end
      {:error, Vex.errors(config)}
    else
      {:ok, config}
    end
  end

  defp print_validation_error({:error, field, _type, msg}) when is_atom(field) do
    error(" - '#{Atom.to_string(field)}' #{msg}")
  end
  defp print_validation_error({:error, field, _type, msg}) when is_list(field) do
    field = Enum.map_join(field, " -> ", &("'#{&1}'"))
    error(" - #{field} #{msg}")
  end

end
