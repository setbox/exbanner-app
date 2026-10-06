defmodule ExBanner do
  alias ExBanner.Colors
  alias ExBanner.Fonts
  alias ExBanner.Renderer
  alias ExBanner.Sanitizer

  @default_width 80

  @type font :: atom() | String.t()
  @type render_option :: {:font, font()} | {:width, pos_integer()}
  @type print_option ::
          render_option() | {:color, atom()} | {:device, IO.device()}

  @spec render(String.t(), [render_option()]) :: {:ok, String.t()} | {:error, term()}
  def render(text, opts \\ []) when is_binary(text) and is_list(opts) do
    with {:ok, width} <- fetch_width(opts),
         {:ok, font} <- Fonts.load(Keyword.get(opts, :font, :standard)) do
      {:ok, Renderer.render(font, Sanitizer.strip(text, [?\n, ?\t]), width)}
    end
  end

  @spec render!(String.t(), [render_option()]) :: String.t()
  def render!(text, opts \\ []) do
    case render(text, opts) do
      {:ok, output} -> output
      {:error, reason} -> raise ExBanner.Error, reason: reason
    end
  end

  @spec print(String.t(), [print_option()]) :: :ok
  def print(text, opts \\ []) when is_binary(text) and is_list(opts) do
    {color, opts} = Keyword.pop(opts, :color)
    {device, opts} = Keyword.pop(opts, :device, :stdio)

    text
    |> render!(opts)
    |> colorize(color)
    |> then(&IO.write(device, &1))
  end

  @spec show() :: :ok
  def show, do: ExBanner.Startup.show()

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
