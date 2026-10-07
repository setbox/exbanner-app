defmodule ExBanner do
  @moduledoc """
  ASCII art banners for Elixir applications.

  ExBanner does two things:

    * prints a startup banner from `priv/banner.txt` when your application
      boots, configured under `config :exbanner`. See the README for the
      startup options, placeholders and colors.
    * renders text with FIGlet fonts, matching the output of `figlet` 2.2.5.

  ## Examples

      ExBanner.print("Hello", font: :slant, color: :gold)

      {:ok, banner} = ExBanner.render("Hello", font: :small)

  Text is sanitized before rendering: control characters and escape
  sequences are removed. Characters the font does not have are rendered
  without accents when possible, and as `?` otherwise.
  """

  alias ExBanner.Colors
  alias ExBanner.Fonts
  alias ExBanner.Renderer
  alias ExBanner.Sanitizer

  @default_width 80

  @typedoc """
  A font: the name of a bundled font or of a font in `:font_paths`, as an atom
  or a string, or a path to a `.flf` file.
  """
  @type font :: atom() | String.t()

  @typedoc "Options accepted by `render/2` and `render!/2`."
  @type render_option :: {:font, font()} | {:width, pos_integer()}

  @typedoc "Options accepted by `print/2`."
  @type print_option ::
          render_option() | {:color, atom()} | {:device, IO.device()}

  @doc """
  Renders `text` as ASCII art.

  ## Options

    * `:font` - the font to use. Defaults to `:standard`. See `fonts/0`.
    * `:width` - the line width. Longer text wraps at word boundaries, like
      `figlet -w`. Defaults to `#{@default_width}`.

  ## Errors

    * `{:unknown_font, name}` - the font was not found.
    * `{:invalid_font, path, reason}` - the font file could not be read or
      is not a FIGlet font.
    * `{:invalid_width, width}` - the width is not a positive integer.

  ## Examples

      iex> ExBanner.render("Hi", font: :term)
      {:ok, "Hi\\n"}

      iex> ExBanner.render("Hi", font: :nope)
      {:error, {:unknown_font, "nope"}}

      iex> ExBanner.render("Hi", width: 0)
      {:error, {:invalid_width, 0}}

  """
  @spec render(String.t(), [render_option()]) :: {:ok, String.t()} | {:error, term()}
  def render(text, opts \\ []) when is_binary(text) and is_list(opts) do
    with {:ok, width} <- fetch_width(opts),
         {:ok, font} <- Fonts.load(Keyword.get(opts, :font, :standard)) do
      {:ok, Renderer.render(font, Sanitizer.strip(text, [?\n, ?\t]), width)}
    end
  end

  @doc """
  Renders `text` as ASCII art, raising `ExBanner.Error` on failure.

  Accepts the same options as `render/2`.

  ## Examples

      iex> ExBanner.render!("Hi", font: :mini)
      "     \\n|_|o \\n| || \\n     \\n"

  """
  @spec render!(String.t(), [render_option()]) :: String.t()
  def render!(text, opts \\ []) do
    case render(text, opts) do
      {:ok, output} -> output
      {:error, reason} -> raise ExBanner.Error, reason: reason
    end
  end

  @doc """
  Renders `text` and writes it to an IO device.

  Raises `ExBanner.Error` when the text cannot be rendered and
  `ArgumentError` for an unknown color.

  ## Options

  Accepts the options of `render/2` and:

    * `:color` - a [Bunt](https://hexdocs.pm/bunt) color or style, such as
      `:red`, `:gold` or `:bright`. Ignored when ANSI is disabled.
    * `:device` - the IO device. Defaults to `:stdio`.

  ## Examples

      ExBanner.print("Hello")
      ExBanner.print("Hello", font: :slant, color: :darkorange)
      ExBanner.print("Hello", device: :stderr)

  """
  @spec print(String.t(), [print_option()]) :: :ok
  def print(text, opts \\ []) when is_binary(text) and is_list(opts) do
    {color, opts} = Keyword.pop(opts, :color)
    {device, opts} = Keyword.pop(opts, :device, :stdio)

    text
    |> render!(opts)
    |> colorize(color)
    |> then(&IO.write(device, &1))
  end

  @doc """
  Prints the startup banner of the application configured in `:otp_app`.

  Prints even when `mode: :off` is set and regardless of `:mix_tasks`, so you
  can disable the automatic banner and call this function where you want it.
  Uses `Logger` when `mode: :log` is set.

  Raises `ArgumentError` when `:otp_app` is not configured.
  """
  @spec show() :: :ok
  def show, do: ExBanner.Startup.show()

  @doc """
  Returns the names of the bundled fonts.

  Fonts in `:font_paths` are not listed, but can be used by name.

  ## Examples

      iex> :standard in ExBanner.fonts()
      true

  """
  @spec fonts() :: [atom()]
  def fonts, do: Fonts.builtin()

  defp fetch_width(opts) do
    case Keyword.get(opts, :width, @default_width) do
      width when is_integer(width) and width > 0 -> {:ok, width}
      width -> {:error, {:invalid_width, width}}
    end
  end

  defp colorize(output, nil), do: output

  defp colorize(output, color) do
    if Colors.valid?(color) do
      [color, output] |> Bunt.ANSI.format() |> IO.iodata_to_binary()
    else
      raise ArgumentError, "unknown color: #{inspect(color)}"
    end
  end
end
