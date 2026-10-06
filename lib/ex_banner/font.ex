defmodule ExBanner.Font do
  @moduledoc false

  import Bitwise

  alias ExBanner.Sanitizer

  defstruct [:hardblank, :height, :layout, :right_to_left, :glyphs]

  @type t :: %__MODULE__{
          hardblank: non_neg_integer(),
          height: pos_integer(),
          layout: non_neg_integer(),
          right_to_left: 0 | 1,
          glyphs: %{integer() => [[non_neg_integer()]]}
        }

  @deutsch [196, 214, 220, 228, 246, 252, 223]
  @whitespace [?\s, ?\t, ?\n, ?\v, ?\f, ?\r]

  @spec parse(binary()) :: {:ok, t()} | {:error, :not_a_figlet_font}
  def parse(data) when is_binary(data) do
    case data |> strip_bom() |> split_lines() do
      ["flf2" <> header | lines] -> parse_header(header, lines)
      _ -> {:error, :not_a_figlet_font}
    end
  end

  defp strip_bom(<<0xEF, 0xBB, 0xBF, rest::binary>>), do: rest
  defp strip_bom(data), do: data

  defp split_lines(data) do
    data
    |> String.split(["\r\n", "\r", "\n"])
    |> Enum.drop(-1)
  end

  defp parse_header(header, lines) do
    with <<_variant::utf8, hardblank::utf8, rest::binary>> <- header,
         [height, _baseline, _max_length, old_layout, comment_lines | optional] <-
           header_integers(rest) do
      height = max(height, 1)
      right_to_left = if Enum.at(optional, 0) == 1, do: 1, else: 0
      layout = full_layout(old_layout, Enum.at(optional, 1))

      glyphs =
        lines
        |> Enum.drop(max(comment_lines, 0))
        |> read_glyphs(height, hardblank)

      {:ok,
       %__MODULE__{
         hardblank: hardblank,
         height: height,
         layout: layout,
         right_to_left: right_to_left,
         glyphs: glyphs
       }}
    else
      _ -> {:error, :not_a_figlet_font}
    end
  end

  defp header_integers(text) do
    text
    |> String.split()
    |> Enum.reduce_while([], fn token, acc ->
      case Integer.parse(token) do
        {value, ""} -> {:cont, [value | acc]}
        {value, _rest} -> {:halt, [value | acc]}
        :error -> {:halt, acc}
      end
    end)
    |> Enum.reverse()
  end

  defp full_layout(_old_layout, full_layout) when is_integer(full_layout), do: full_layout
  defp full_layout(0, nil), do: 64
  defp full_layout(old_layout, nil) when old_layout < 0, do: 0
  defp full_layout(old_layout, nil), do: (old_layout &&& 31) ||| 128

  defp read_glyphs(lines, height, hardblank) do
    codes = Enum.to_list(?\s..?~) ++ @deutsch

    {glyphs, rest} =
      Enum.reduce(codes, {%{}, lines}, fn code, {glyphs, lines} ->
        {rows, rest} = read_rows(lines, height, hardblank)
        {Map.put(glyphs, code, rows), rest}
      end)

    read_tagged_glyphs(rest, height, hardblank, glyphs)
  end

  defp read_tagged_glyphs([], _height, _hardblank, glyphs), do: glyphs

  defp read_tagged_glyphs([tag | lines], height, hardblank, glyphs) do
    case parse_code(tag) do
      {:ok, code} ->
        {rows, rest} = read_rows(lines, height, hardblank)
        read_tagged_glyphs(rest, height, hardblank, Map.put(glyphs, code, rows))

      :error ->
        glyphs
    end
  end

  defp parse_code(tag) do
    {sign, digits} =
      case String.trim_leading(tag) do
        "-" <> digits -> {-1, digits}
        "+" <> digits -> {1, digits}
        digits -> {1, digits}
      end

    case parse_unsigned(digits) do
      {:ok, value} -> {:ok, sign * value}
      :error -> :error
    end
  end

  defp parse_unsigned(<<"0", x, rest::binary>>) when x in [?x, ?X], do: leading_integer(rest, 16)
  defp parse_unsigned(<<"0", rest::binary>>), do: leading_integer("0" <> rest, 8)
  defp parse_unsigned(digits), do: leading_integer(digits, 10)

  defp leading_integer(digits, base) do
    case Integer.parse(digits, base) do
      {value, _rest} -> {:ok, value}
      :error -> :error
    end
  end

  defp read_rows(lines, height, hardblank) do
    {taken, rest} = Enum.split(lines, height)

    rows =
      Enum.map(taken, &parse_row(&1, hardblank)) ++ List.duplicate([], height - length(taken))

    {rows, rest}
  end

  defp parse_row(line, hardblank) do
    line
    |> decode()
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 in @whitespace))
    |> drop_endmarks()
    |> Enum.reverse()
    |> Enum.reject(&(&1 != hardblank and Sanitizer.control?(&1)))
  end

  defp decode(line) do
    if String.valid?(line) do
      String.to_charlist(line)
    else
      :unicode.characters_to_list(line, :latin1)
    end
  end

  defp drop_endmarks([]), do: []
  defp drop_endmarks([endmark | _] = reversed), do: Enum.drop_while(reversed, &(&1 == endmark))
end
