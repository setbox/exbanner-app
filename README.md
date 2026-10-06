# ExBanner

```
    ______     ____
   / ____/  __/ __ )____ _____  ____  ___  _____
  / __/ | |/_/ __  / __ `/ __ \/ __ \/ _ \/ ___/
 / /____>  </ /_/ / /_/ / / / / / / /  __/ /
/_____/_/|_/_____/\__,_/_/ /_/_/ /_/\___/_/
```

ASCII art banners for Elixir applications.

- Prints a startup banner from `priv/banner.txt` when your application boots.
- Renders text with FIGlet fonts: `ExBanner.print("Hello", font: :slant)`.
- Output matches `figlet` 2.2.5 byte for byte, including smushing and word wrapping.
- 26 bundled fonts, all with licenses that allow redistribution.

## Installation

```elixir
def deps do
  [
    {:ex_banner, "~> 0.1"}
  ]
end
```

Requires Elixir 1.15+ and OTP 25+.

## Startup banner

Tell ExBanner which application owns the banner:

```elixir
# config/config.exs
config :ex_banner, otp_app: :my_app
```

Then create `priv/banner.txt` in your application:

```
$[gold] __  __            _
|  \/  |_   _      / \   _ __  _ __
| |\/| | | | |    / _ \ | '_ \| '_ \
| |  | | |_| |   / ___ \| |_) | |_) |
|_|  |_|\__, |  /_/   \_\ .__/| .__/
        |___/           |_|   |_|$[reset]
$[dimgray]$app v$version | Elixir $elixir_version | OTP $otp_release$[reset]
```

ExBanner starts before your application, so the banner is printed before any of your logs. It works with `mix run`, `iex -S mix`, `mix phx.server` and releases.

Without `otp_app` ExBanner prints nothing, so a library that depends on ExBanner never prints a banner in your application unless you opt in. When `otp_app` is set and `priv/banner.txt` does not exist, ExBanner prints a default banner with the application name in the `:standard` font.

A failure while printing the startup banner is logged as a warning and never stops your application.

### Placeholders

`banner.txt` is plain text. ExBanner replaces these placeholders, in the same style as `Logger` formats:

| Placeholder | Value |
|---|---|
| `$app` | The `otp_app` name |
| `$version` | Application version |
| `$description` | Application description |
| `$elixir_version` | `System.version()` |
| `$otp_release` | `System.otp_release()` |
| `$ex_banner_version` | ExBanner version |
| `$node` | `node()` |
| `$hostname` | Host name |
| `$release` | `RELEASE_NAME`, empty outside a release |
| `$schedulers` | `System.schedulers_online()` |

Only known names are replaced. Any other `$` stays as written, so ASCII art with `$$$$` is safe. A placeholder is read as a whole word: `$app_name` is not `$app` followed by `_name`, and stays literal.

Add your own values with `:vars`, as a map, a keyword list or an `{module, function, args}` tuple that returns one. Your values win over the built-in ones.

```elixir
config :ex_banner, otp_app: :my_app, vars: %{env: config_env()}
```

### Colors

Write any [Bunt](https://hex.pm/packages/bunt) color or style between brackets: `$[red]`, `$[gold]`, `$[darkorange]`, `$[bright]`, `$[underline]`, `$[reset]`. Background colors use the `_background` suffix, as in `$[darkblue_background]`.

ExBanner adds a reset at the end of a banner that uses colors. Colors are removed when ANSI is disabled and in `:log` mode. Unknown colors stay in the text and are logged as a warning. Sequences that move the cursor or clear the screen are not accepted.

### Configuration

| Option | Default | Description |
|---|---|---|
| `:otp_app` | `nil` | Application that owns the banner. Required to print anything. |
| `:location` | `priv/banner.txt` of `:otp_app` | A path, or `{:priv, app, "file.txt"}`. A missing file logs a warning and prints the default banner. |
| `:mode` | `:console` | `:console` writes to stdout, `:log` uses `Logger.info/1`, `:off` disables the startup banner. |
| `:mix_tasks` | `:all` | `:all`, `:none`, or a list of task names such as `["phx.server", "run"]`. |
| `:vars` | `%{}` | Extra placeholders. |
| `:font_paths` | `[]` | Directories with your own `.flf` fonts. |

The startup banner also appears in mix tasks such as `mix test` and `mix ecto.migrate`. To limit it:

```elixir
# only when the application runs
config :ex_banner, mix_tasks: ["phx.server", "run"]

# or never in tests
# config/test.exs
config :ex_banner, mode: :off
```

`iex -S mix` counts as `run`. Releases have no mix tasks and always print the banner.

To print the banner yourself, set `mode: :off` and call `ExBanner.show/0` where you want it.

## Rendering text

```elixir
iex> ExBanner.print("Hello", font: :small)
 _  _     _ _
| || |___| | |___
| __ / -_) | / _ \
|_||_\___|_|_\___/
:ok

iex> ExBanner.render("Hello", font: :slant)
{:ok, "    __  __     ____    \n ..."}

iex> ExBanner.render!("Hello")
" _   _      _ _       \n ..."

iex> ExBanner.render("Hello", font: :crazy)
{:error, {:unknown_font, "crazy"}}
```

| Function | Returns |
|---|---|
| `render(text, opts)` | `{:ok, string}` or `{:error, reason}` |
| `render!(text, opts)` | The string, or raises `ExBanner.Error` |
| `print(text, opts)` | `:ok`, raises on errors |
| `show()` | Prints the startup banner, ignoring `mode: :off` and `:mix_tasks` |
| `fonts()` | The bundled font names |

Options:

| Option | Default | Description |
|---|---|---|
| `:font` | `:standard` | A bundled font, a font in `:font_paths`, or a path to a `.flf` file |
| `:width` | `80` | Line width. Longer text wraps at word boundaries, like `figlet -w`. |
| `:color` | `nil` | Bunt color, `print/2` only |
| `:device` | `:stdio` | IO device, `print/2` only |

Characters the font does not have are rendered without accents when possible (`ç` becomes `c`), and as `?` otherwise. They are never dropped silently.

## Fonts

| Font | License | Source |
|---|---|---|
| `:banner` | BSD-3-Clause | FIGlet 2.2.5 |
| `:big` | BSD-3-Clause | FIGlet 2.2.5 |
| `:block` | BSD-3-Clause | FIGlet 2.2.5 |
| `:bubble` | BSD-3-Clause | FIGlet 2.2.5 |
| `:digital` | BSD-3-Clause | FIGlet 2.2.5 |
| `:ivrit` | BSD-3-Clause | FIGlet 2.2.5 |
| `:lean` | BSD-3-Clause | FIGlet 2.2.5 |
| `:mini` | BSD-3-Clause | FIGlet 2.2.5 |
| `:mnemonic` | BSD-3-Clause | FIGlet 2.2.5 |
| `:script` | BSD-3-Clause | FIGlet 2.2.5 |
| `:shadow` | BSD-3-Clause | FIGlet 2.2.5 |
| `:slant` | BSD-3-Clause | FIGlet 2.2.5 |
| `:small` | BSD-3-Clause | FIGlet 2.2.5 |
| `:small_script` | BSD-3-Clause | FIGlet 2.2.5 |
| `:small_shadow` | BSD-3-Clause | FIGlet 2.2.5 |
| `:small_slant` | BSD-3-Clause | FIGlet 2.2.5 |
| `:standard` | BSD-3-Clause | FIGlet 2.2.5 |
| `:term` | BSD-3-Clause | FIGlet 2.2.5 |
| `:ansi_compact` | MIT | Loic Cressot |
| `:classy` | MIT | Loic Cressot |
| `:coder_mini` | MIT | Loic Cressot |
| `:font_font` | MIT | Oscar Cole |
| `:linguaholic_mini_block` | MIT | Linguaholic |
| `:linguaholic_neon` | MIT | Linguaholic |
| `:linguaholic_rounded` | MIT | Linguaholic |
| `:linguaholic_shadow_3d` | MIT | Linguaholic |

### Your own fonts

Popular fonts such as Crazy, Doom, Epic or ANSI Shadow are not bundled because their files carry no license that allows redistribution. The full list, with the reason for each font, is in [ISSUES.md](https://github.com/dakoctba/ex_banner/blob/master/ISSUES.md).

You can still use them. Download the `.flf` file and point ExBanner to its directory:

```elixir
config :ex_banner, font_paths: [Path.expand("../priv/fonts", __DIR__)]
```

```elixir
ExBanner.print("Hello", font: :crazy)
ExBanner.print("Hello", font: "/path/to/crazy.flf")
```

Fonts in `:font_paths` take precedence over bundled fonts with the same name. Fonts are parsed on first use and cached with `:persistent_term`.

## Security

ExBanner never evaluates code from `banner.txt` or from font files. Control characters, ANSI escape sequences and Unicode bidirectional overrides are removed from `banner.txt`, from placeholder values, from rendered text and from font glyphs, so a hostname or an environment variable cannot inject terminal sequences or fake log lines. Placeholder values are always a single line. Only ExBanner emits ANSI sequences, from a fixed list of colors and styles. Font and color names are never converted to atoms.

## License

ExBanner is released under the MIT license. Bundled fonts keep their own licenses: see [LICENSE](LICENSE) and `priv/fonts/LICENSE.figlet`.
