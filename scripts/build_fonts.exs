Mix.install([{:exbanner, path: Path.expand("..", __DIR__)}])

fonts =
  Enum.map(ExBanner.fonts(), fn font ->
    %{name: Atom.to_string(font), art: ExBanner.render!("ExBanner", font: font, width: 400)}
  end)

site =
  case System.argv() do
    [path] -> Path.expand(path)
    [] -> Path.expand("~/workspace/setbox/sites/setbox.github.io/oss/exbanner")
  end

output = Path.join(site, "assets/scripts/fonts.js")
File.write!(output, "window.EXBANNER_FONTS = " <> JSON.encode!(fonts) <> ";\n")
IO.puts("#{length(fonts)} fonts written to #{Path.relative_to_cwd(output)}")
