defmodule ExrmDebTest.GenerateTemplatesTest do
  use ExUnit.Case

  test "Check that mix task copies over the config to the correct dir" do
    dest = [Path.dirname(__DIR__), "templates"] |> Path.join
    assert :ok = File.mkdir_p!(dest)
    assert Mix.Tasks.Release.Deb.GenerateTemplates.copy_templates(dest)
    assert [dest, "changelog.eex"] |> Path.join |> File.exists?
    assert [dest, "control.eex"] |> Path.join |> File.exists?
    assert [dest, "init_scripts", "systemd.service.eex"] |> Path.join |> File.exists?
    assert [dest, "init_scripts", "upstart.conf.eex"] |> Path.join |> File.exists?
    assert File.rm_rf!(dest)
  end

end
