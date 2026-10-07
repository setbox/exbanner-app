defmodule ExBanner.Showcase do
  @moduledoc false

  alias ExBanner.Colors
  alias ExBanner.Fonts
  alias ExBanner.Renderer
  alias ExBanner.Sanitizer

  @spec run(String.t(), pos_integer(), keyword()) :: :ok
  def run(text, width, opts) do
    settings = %{
      text: Sanitizer.strip(text, [?\n, ?\t]),
      width: width,
      device: Keyword.get(opts, :device, :stdio),
      color: Keyword.get(opts, :color),
      page_size: Keyword.get(opts, :page_size, 50)
    }

    case entries(opts) do
      [] -> IO.write(settings.device, "No fonts match #{inspect(Keyword.get(opts, :match))}\n")
      entries -> show(entries, length(entries), 1, settings)
    end
  end

  defp entries(opts) do
    match = opts |> Keyword.get(:match) |> normalize_match()

    opts
    |> Keyword.get(:fonts)
    |> case do
      nil -> Enum.map(Fonts.builtin(), &{&1, :builtin})
      fonts -> Enum.map(fonts, &{&1, {:loaded, load!(&1)}})
    end
    |> Enum.filter(fn {font, _source} -> matches?(font, match) end)
  end

  defp normalize_match(nil), do: nil
  defp normalize_match(match) when is_binary(match), do: String.downcase(match)

  defp matches?(_font, nil), do: true

  defp matches?(font, match),
    do: font |> to_string() |> String.downcase() |> String.contains?(match)

  defp show([], _total, _position, _settings), do: :ok

  defp show([entry | rest], total, position, settings) do
    IO.write(settings.device, block(entry, total, position, settings))

    if rest != [] and page_end?(position, settings.page_size) do
      case prompt(position, total, settings.device) do
        :quit -> :ok
        :next -> show(rest, total, position + 1, settings)
        :all -> show(rest, total, position + 1, %{settings | page_size: :infinity})
      end
    else
      show(rest, total, position + 1, settings)
    end
  end

  defp block({font, source}, total, position, settings) do
    output =
      source
      |> font_for(font)
      |> Renderer.render(settings.text, settings.width)
      |> Colors.colorize(settings.color)

    [header(font, total, position), "\n", output, "\n"]
  end

  defp font_for({:loaded, font}, _name), do: font
  defp font_for(:builtin, name), do: load!(name)

  defp load!(font) do
    case Fonts.load(font, cache: false) do
      {:ok, loaded} -> loaded
      {:error, reason} -> raise ExBanner.Error, reason: reason
    end
  end

  defp header(font, total, position) do
    label = "font: #{inspect(font)}  (#{position}/#{total})"

    if Bunt.ANSI.enabled?(),
      do: Colors.sequence(:bright) <> label <> Colors.sequence(:reset),
      else: label
  end

  defp page_end?(_position, :infinity), do: false
  defp page_end?(position, page_size), do: rem(position, page_size) == 0

  defp prompt(position, total, device) do
    IO.write(device, "-- #{position} of #{total} fonts, Enter for more, q to quit --\n")

    case IO.gets(:stdio, "") do
      answer when is_binary(answer) ->
        if String.trim(answer) in ["q", "Q"], do: :quit, else: :next

      _eof_or_error ->
        :all
    end
  end
end
