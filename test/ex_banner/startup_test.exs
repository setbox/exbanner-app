defmodule ExBanner.StartupTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO
  import ExUnit.CaptureLog

  alias ExBanner.Startup

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    ansi_enabled = Application.get_env(:elixir, :ansi_enabled)
    Application.put_env(:elixir, :ansi_enabled, false)

    on_exit(fn ->
      Application.put_env(:elixir, :ansi_enabled, ansi_enabled)

      for key <- [:otp_app, :location, :mode, :mix_tasks, :vars] do
        Application.delete_env(:ex_banner, key)
      end
    end)

    banner = Path.join(tmp_dir, "banner.txt")
    Application.put_env(:ex_banner, :otp_app, :ex_banner)
    Application.put_env(:ex_banner, :location, banner)
    Application.put_env(:ex_banner, :mix_tasks, :all)

    %{banner: banner}
  end

  test "prints banner.txt with placeholders", %{banner: banner} do
    File.write!(banner, "BANNER $app v$version | Elixir $elixir_version | $unknown\n")

    assert capture_io(&Startup.run/0) ==
             "BANNER ex_banner v#{Application.spec(:ex_banner, :vsn)} | Elixir #{System.version()} | $unknown\n"
  end

  test "stays silent without otp_app", %{banner: banner} do
    File.write!(banner, "BANNER\n")
    Application.delete_env(:ex_banner, :otp_app)

    assert capture_io(&Startup.run/0) == ""
  end

  test "stays silent when mode is off", %{banner: banner} do
    File.write!(banner, "BANNER\n")
    Application.put_env(:ex_banner, :mode, :off)

    assert capture_io(&Startup.run/0) == ""
  end

  test "logs the banner when mode is log", %{banner: banner} do
    File.write!(banner, "$[red]BANNER $app\n")
    Application.put_env(:ex_banner, :mode, :log)

    log = capture_log(fn -> assert capture_io(&Startup.run/0) == "" end)

    assert log =~ "BANNER ex_banner"
    refute log =~ "\e[31m"
  end

  test "stays silent when mix tasks are disabled", %{banner: banner} do
    File.write!(banner, "BANNER\n")
    Application.put_env(:ex_banner, :mix_tasks, :none)

    assert capture_io(&Startup.run/0) == ""
  end

  test "show/0 prints even when mode is off", %{banner: banner} do
    File.write!(banner, "BANNER\n")
    Application.put_env(:ex_banner, :mode, :off)

    assert capture_io(&ExBanner.show/0) == "BANNER\n"
  end

  test "show/0 requires otp_app" do
    Application.delete_env(:ex_banner, :otp_app)

    assert_raise ArgumentError, fn -> ExBanner.show() end
  end

  test "sanitizes banner.txt and placeholder values", %{banner: banner} do
    File.write!(banner, "A\e]0;title\a\tB\r\n$evil|$count|$name\n")

    Application.put_env(:ex_banner, :vars,
      evil: "x\nFAKE LOG LINE\e[2J",
      count: 3,
      name: :atom
    )

    assert capture_io(&Startup.run/0) == "A]0;title\tB\nxFAKE LOG LINE[2J|3|atom\n"
  end

  test "user vars override builtin vars and accept an MFA", %{banner: banner} do
    File.write!(banner, "$app $env\n")
    Application.put_env(:ex_banner, :vars, {Map, :new, [[{"app", "custom"}, {:env, "prod"}]]})

    assert capture_io(&Startup.run/0) == "custom prod\n"
  end

  test "prints the default banner when the file is missing" do
    Application.delete_env(:ex_banner, :location)

    output = capture_io(&Startup.run/0)

    assert output =~ ExBanner.render!("ex_banner")

    assert output =~
             "ex_banner v#{Application.spec(:ex_banner, :vsn)} | Elixir #{System.version()}"
  end

  test "warns and falls back to the default banner when location is missing", %{
    banner: banner
  } do
    log =
      capture_log(fn -> assert capture_io(&Startup.run/0) =~ ExBanner.render!("ex_banner") end)

    assert log =~ "could not find #{banner}"
  end

  test "warns about unknown colors", %{banner: banner} do
    File.write!(banner, "$[clear]BANNER\n")

    log = capture_log(fn -> assert capture_io(&Startup.run/0) == "$[clear]BANNER\n" end)

    assert log =~ "unknown color $[clear]"
  end

  test "never crashes the host application" do
    Application.put_env(:ex_banner, :otp_app, :not_an_app)
    Application.delete_env(:ex_banner, :location)

    log = capture_log(fn -> assert Startup.run() == :ok end)

    assert log =~ "could not print the startup banner"
  end

  test "detects the current mix task from the command line" do
    assert Startup.mix_task_from_arguments(["/usr/bin/mix", "ecto.migrate"]) == "ecto.migrate"
    assert Startup.mix_task_from_arguments(["/usr/bin/mix"]) == "run"
    assert Startup.mix_task_from_arguments(["--no-halt", "+iex", "-S", "mix"]) == "run"
    assert Startup.mix_task_from_arguments(["-S", "mix", "phx.server"]) == "phx.server"
    assert Startup.mix_task_from_arguments(["-S", "mix", "--version"]) == "run"
    assert Startup.mix_task_from_arguments([]) == nil
  end

  test "filters mix tasks" do
    assert Startup.mix_task_allowed?(:all, "test")
    refute Startup.mix_task_allowed?(:none, "phx.server")
    assert Startup.mix_task_allowed?(["phx.server"], "phx.server")
    refute Startup.mix_task_allowed?(["phx.server"], "ecto.migrate")
    assert Startup.mix_task_allowed?(:none, nil)
  end
end
