defmodule ExBanner.FontTest do
  use ExUnit.Case, async: false

  alias ExBanner.Font

  @standard Path.expand("../../priv/fonts/standard.flf", __DIR__)

  test "rejects files that are not FIGlet fonts" do
    assert Font.parse("hello\n") == {:error, :not_a_figlet_font}
    assert Font.parse("flf2a$ 1\n") == {:error, :not_a_figlet_font}
  end

  test "parses fonts with BOM and CRLF line endings" do
    data = File.read!(@standard)
    {:ok, font} = Font.parse(data)

    assert Font.parse(<<0xEF, 0xBB, 0xBF>> <> String.replace(data, "\n", "\r\n")) == {:ok, font}
  end

  test "reads code tagged glyphs and removes endmarks" do
    header = "flf2a$ 1 1 4 0 0\n"
    ascii = String.duplicate("x@\n", 95 + 7)
    {:ok, font} = Font.parse(header <> ascii <> "0x2603 SNOWMAN\n*#@@\n")

    assert font.glyphs[0x2603] == [~c"*#"]
    assert font.glyphs[?A] == [~c"x"]
  end

  test "strips control characters from glyphs but keeps the hardblank" do
    header = "flf2a\x7F 1 1 4 0 0\n"
    ascii = String.duplicate("\x7Fa\e[2J@\n", 95 + 7)
    {:ok, font} = Font.parse(header <> ascii)

    assert font.glyphs[?A] == [[0x7F, ?a, ?[, ?2, ?J]]
  end

  describe "user fonts" do
    @describetag :tmp_dir

    setup %{tmp_dir: tmp_dir} do
      File.cp!(@standard, Path.join(tmp_dir, "custom.flf"))
      Application.put_env(:ex_banner, :font_paths, [tmp_dir])
      on_exit(fn -> Application.delete_env(:ex_banner, :font_paths) end)
    end

    test "resolves atoms from font_paths", %{tmp_dir: tmp_dir} do
      assert ExBanner.render!("Hi", font: :custom) == ExBanner.render!("Hi")

      assert ExBanner.render!("Hi", font: Path.join(tmp_dir, "custom.flf")) ==
               ExBanner.render!("Hi")
    end

    test "rejects invalid font files", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "broken.flf")
      File.write!(path, "not a font")

      assert ExBanner.render("Hi", font: :broken) ==
               {:error, {:invalid_font, path, :not_a_figlet_font}}
    end

    test "rejects font files that are too large", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "huge.flf")
      File.write!(path, :binary.copy("x", 2_000_001))

      assert ExBanner.render("Hi", font: :huge) == {:error, {:invalid_font, path, :too_large}}
    end
  end
end
