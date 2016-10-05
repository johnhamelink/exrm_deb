defmodule ExrmDebTest.ConfigTest do
  use ExUnit.Case

  test "Configuration is sanitized correctly" do
    out = ExrmDeb.Utils.Config.sanitize_config(%{ name: "$!JIM-B+O.B,'" })
    assert Map.fetch!(out, :sanitized_name)
    assert Map.fetch!(out, :sanitized_name) == "jim-b+o.b"
  end

  test "building default config works correctly" do
    assert {:ok, _} = ExrmDeb.Config.build_config
  end

  test "building an invalid config results in an error being raised" do
    assert {:error, [{:error, :description, :presence, "must be present"}]} =
           ExrmDeb.Config.build_config(%{description: nil})
  end

  test "owner must have both user and group" do
    assert {:error,
            [{:error,
              [:owner, :group],
              :presence,
              "must be present"}]} =
      ExrmDeb.Config.build_config(%{owner: [user: "root"]})
  end

end
