defmodule ExBanner.GoldenTest do
  use ExUnit.Case, async: true

  @golden Path.expand("../fixtures/golden", __DIR__)

  @cases "../support/golden_cases.tsv"
         |> Path.expand(__DIR__)
         |> File.read!()
         |> String.split("\n", trim: true)
         |> Enum.map(&String.split(&1, "\t"))

  for font <- ExBanner.fonts(), [name, width, text] <- @cases do
    @tag font: font
    test "#{font} renders #{name} like figlet 2.2.5" do
      expected =
        File.read!(Path.join([@golden, unquote(Atom.to_string(font)), unquote(name) <> ".txt"]))

      text = String.replace(unquote(text), "\\n", "\n")

      assert ExBanner.render!(text, font: unquote(font), width: unquote(String.to_integer(width))) ==
               expected
    end
  end
end
