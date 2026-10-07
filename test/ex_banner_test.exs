defmodule ExBannerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  doctest ExBanner

  test "render/2 uses the standard font by default" do
    assert ExBanner.render("Hi") == ExBanner.render("Hi", font: :standard)
  end

  test "render/2 returns an error for an unknown font" do
    assert ExBanner.render("Hi", font: :nope) == {:error, {:unknown_font, "nope"}}
  end

  test "render/2 rejects font names that could escape the font directories" do
    assert ExBanner.render("Hi", font: "../standard") == {:error, {:unknown_font, "../standard"}}
    assert ExBanner.render("Hi", font: "stan dard") == {:error, {:unknown_font, "stan dard"}}
  end

  test "render/2 returns an error for an invalid width" do
    assert ExBanner.render("Hi", width: 0) == {:error, {:invalid_width, 0}}
    assert ExBanner.render("Hi", width: "80") == {:error, {:invalid_width, "80"}}
  end

  test "render!/2 raises ExBanner.Error" do
    assert_raise ExBanner.Error, "unknown font: nope", fn ->
      ExBanner.render!("Hi", font: :nope)
    end
  end

  test "render/2 transliterates characters missing from the font" do
    assert ExBanner.render!("Ação", font: :banner) == ExBanner.render!("Acao", font: :banner)
  end

  test "render/2 keeps glyphs the font defines" do
    refute ExBanner.render!("ç", font: :standard) == ExBanner.render!("c", font: :standard)
  end

  test "render/2 falls back to the question mark glyph" do
    assert ExBanner.render!("🙂", font: :banner) == ExBanner.render!("?", font: :banner)
  end

  test "render/2 strips control characters and escape sequences" do
    assert ExBanner.render!("A\e[2JB\u202E") == ExBanner.render!("A[2JB")
    refute ExBanner.render!("A\e[31mB") =~ "\e"
  end

  test "print/2 writes the rendered text to the device" do
    assert capture_io(fn -> assert ExBanner.print("Hi") == :ok end) == ExBanner.render!("Hi")
  end

  test "print/2 writes to stderr" do
    assert capture_io(:stderr, fn -> ExBanner.print("Hi", device: :stderr) end) ==
             ExBanner.render!("Hi")
  end

  test "print/2 raises on unknown color" do
    assert_raise ArgumentError, "unknown color: :clear", fn ->
      ExBanner.print("Hi", color: :clear)
    end
  end

  test "print/2 raises on unknown font" do
    assert_raise ExBanner.Error, fn -> ExBanner.print("Hi", font: :nope) end
  end

  test "fonts/0 lists the bundled fonts" do
    fonts = ExBanner.fonts()

    assert length(fonts) == 333
    assert :standard in fonts

    for font <- fonts do
      assert {:ok, _output} = ExBanner.render("Hi", font: font)
    end
  end
end
