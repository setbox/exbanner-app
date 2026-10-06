defmodule ExBanner.TemplateTest do
  use ExUnit.Case, async: true

  alias ExBanner.Template

  @vars %{"app" => "my_app", "version" => "1.2.0"}

  test "replaces known placeholders" do
    assert Template.expand("$app v$version", @vars, false) == {"my_app v1.2.0", []}
  end

  test "keeps unknown placeholders and stray dollar signs" do
    assert Template.expand("$app_name $$$ $ $1 $App", @vars, false) ==
             {"$app_name $$$ $ $1 $App", []}
  end

  test "removes colors when ANSI is disabled" do
    assert Template.expand("$[gold]$app$[reset]", @vars, false) == {"my_app", []}
  end

  test "emits colors and a final reset when ANSI is enabled" do
    {output, []} = Template.expand("$[red]$app", @vars, true)

    assert output == "\e[31mmy_app\e[0m"
  end

  test "keeps unknown colors and reports them" do
    assert Template.expand("$[clear]$[nope]$app", @vars, true) ==
             {"$[clear]$[nope]my_app", ["clear", "nope"]}
  end

  test "does not reset when no color was used" do
    assert Template.expand("$app", @vars, true) == {"my_app", []}
  end
end
