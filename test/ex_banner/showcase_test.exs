defmodule ExBanner.ShowcaseTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    ansi_enabled = Application.get_env(:elixir, :ansi_enabled)
    Application.put_env(:elixir, :ansi_enabled, false)
    on_exit(fn -> Application.put_env(:elixir, :ansi_enabled, ansi_enabled) end)
  end

  defp headers(output) do
    ~r/^font: (.+)  \((\d+)\/(\d+)\)$/m
    |> Regex.scan(output, capture: :all_but_first)
  end

  test "shows every bundled font with a header and its position" do
    output = capture_io(fn -> assert ExBanner.showcase("Hi", page_size: :infinity) == :ok end)

    assert length(headers(output)) == length(ExBanner.fonts())
    assert output =~ "font: :standard  ("
    assert output =~ ExBanner.render!("Hi", font: :standard)
  end

  test "shows the given fonts, with names ready to paste" do
    output =
      capture_io(fn ->
        ExBanner.showcase("Hi", fonts: [:"3_d", :term], page_size: :infinity)
      end)

    assert headers(output) == [[~s(:"3_d"), "1", "2"], [":term", "2", "2"]]
    assert output =~ "font: :term  (2/2)\nHi\n\n"
  end

  test "filters fonts by name, ignoring case" do
    output = capture_io(fn -> ExBanner.showcase("Hi", match: "SMALL_S", page_size: :infinity) end)

    assert Enum.map(headers(output), &hd/1) == [":small_script", ":small_shadow", ":small_slant"]
  end

  test "combines fonts and match" do
    output =
      capture_io(fn ->
        ExBanner.showcase("Hi", fonts: [:slant, :small_slant, :big], match: "slant")
      end)

    assert Enum.map(headers(output), &hd/1) == [":slant", ":small_slant"]
  end

  test "reports a search without results" do
    assert capture_io(fn -> ExBanner.showcase("Hi", match: "xyz") end) ==
             ~s(No fonts match "xyz"\n)
  end

  test "pauses between pages and stops on q" do
    output =
      capture_io([input: "q\n"], fn ->
        ExBanner.showcase("Hi", fonts: [:term, :mini, :standard], page_size: 2)
      end)

    assert output =~ "-- 2 of 3 fonts, Enter for more, q to quit --"
    assert Enum.map(headers(output), &hd/1) == [":term", ":mini"]
  end

  test "continues on Enter" do
    output =
      capture_io([input: "\n"], fn ->
        ExBanner.showcase("Hi", fonts: [:term, :mini, :standard], page_size: 2)
      end)

    assert Enum.map(headers(output), &hd/1) == [":term", ":mini", ":standard"]
  end

  test "prints everything when there is no input to read" do
    output =
      capture_io([input: ""], fn ->
        ExBanner.showcase("Hi", fonts: [:term, :mini, :standard, :slant, :big], page_size: 2)
      end)

    assert length(headers(output)) == 5
    assert length(Regex.scan(~r/Enter for more/, output)) == 1
  end

  test "validates the given fonts before printing" do
    output =
      capture_io(fn ->
        assert_raise ExBanner.Error, "unknown font: nope", fn ->
          ExBanner.showcase("Hi", fonts: [:term, :nope])
        end
      end)

    assert output == ""
  end

  test "rejects invalid options" do
    assert_raise ArgumentError, ~r/page_size/, fn -> ExBanner.showcase("Hi", page_size: 0) end
    assert_raise ArgumentError, ~r/match/, fn -> ExBanner.showcase("Hi", match: :slant) end

    assert_raise ArgumentError, ~r/unknown color/, fn ->
      ExBanner.showcase("Hi", color: :clear)
    end

    assert_raise ExBanner.Error, ~r/invalid width/, fn -> ExBanner.showcase("Hi", width: 0) end
  end

  @tag :tmp_dir
  test "does not keep fonts in the cache", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "custom.flf")
    File.cp!(Path.expand("../../priv/fonts/standard.flf", __DIR__), path)

    capture_io(fn -> ExBanner.showcase("Hi", fonts: [path]) end)

    assert :persistent_term.get({ExBanner.Fonts, path}, nil) == nil
  end

  test "highlights headers when ANSI is enabled" do
    Application.put_env(:elixir, :ansi_enabled, true)

    output = capture_io(fn -> ExBanner.showcase("Hi", fonts: [:term]) end)

    assert output =~ "\e[1mfont: :term  (1/1)\e[0m"
  end
end
