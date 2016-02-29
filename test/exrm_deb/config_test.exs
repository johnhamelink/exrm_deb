defmodule ExrmDebTest.ConfigTest do
  use ExUnit.Case

  test "Configuration is sanitized correctly" do
    out = ExrmDeb.Utils.Config.sanitize_config(%{ name: "$!JIM-B+O.B,'" })
    assert Map.fetch!(out, :sanitized_name)
    assert Map.fetch!(out, :sanitized_name) == "jim-b+o.b"
  end

end
