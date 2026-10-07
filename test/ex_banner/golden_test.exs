defmodule ExBanner.GoldenTest do
  use ExUnit.Case, async: true

  @golden Path.expand("../fixtures/golden", __DIR__)

  @cases "../support/golden_cases.tsv"
         |> Path.expand(__DIR__)
         |> File.read!()
         |> String.split("\n", trim: true)
         |> Enum.map(&String.split(&1, "\t"))

  @figlet_differs %{
    diet_cola: "glyphs with uneven rows make figlet read uninitialized memory",
    js_capital_curves: "glyphs with uneven rows make figlet read uninitialized memory",
    stforek: "glyphs with uneven rows make figlet read uninitialized memory",
    pyramid: "figlet decodes the non UTF-8 hardblank 0x81 as garbage bytes"
  }

  for font <- ExBanner.fonts(),
      not Map.has_key?(@figlet_differs, font),
      [name, width, text] <- @cases do
    @tag font: font
    test "#{font} renders #{name} like figlet 2.2.5" do
      expected =
        File.read!(Path.join([@golden, unquote(Atom.to_string(font)), unquote(name) <> ".txt"]))

      text = String.replace(unquote(text), "\\n", "\n")

      assert ExBanner.render!(text, font: unquote(font), width: unquote(String.to_integer(width))) ==
               expected
    end
  end

  for {font, reason} <- @figlet_differs do
    test "#{font} renders clean output where #{reason}" do
      for [_name, width, text] <- @cases do
        output =
          ExBanner.render!(String.replace(text, "\\n", "\n"),
            font: unquote(font),
            width: String.to_integer(width)
          )

        refute output =~ ~r/[\x00-\x09\x0B-\x1F]/
      end
    end
  end
end
