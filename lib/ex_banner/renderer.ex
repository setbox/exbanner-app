defmodule ExBanner.Renderer do
  @moduledoc false

  import Bitwise

  alias ExBanner.Font

  @sm_equal 1
  @sm_lowline 2
  @sm_hierarchy 4
  @sm_pair 8
  @sm_bigx 16
  @sm_hardblank 32
  @sm_kern 64
  @sm_smush 128

  @lowline_set ~c"|/\\[]{}()<>"

  @spec render(Font.t(), String.t(), pos_integer()) :: String.t()
  def render(%Font{} = font, text, width) when is_binary(text) and is_integer(width) do
    text
    |> String.to_charlist()
    |> Enum.map(&resolve(&1, font.glyphs))
    |> Enum.reduce(new_state(font, width), &feed/2)
    |> finish()
    |> Map.fetch!(:out)
    |> IO.iodata_to_binary()
  end

  defp new_state(font, width) do
    %{
      font: font,
      width: width,
      limit: width - 1,
      inchr_limit: width * 4 + 100,
      justification: 2 * font.right_to_left,
      rows: empty_rows(font.height),
      outlinelen: 0,
      inchr: [],
      inchr_len: 0,
      glyph: empty_rows(font.height),
      prev_width: 0,
      curr_width: 0,
      wordbreak: 0,
      out: []
    }
  end

  defp empty_rows(height), do: List.duplicate([], height)

  defp resolve(char, _glyphs) when char in [?\s, ?\t], do: ?\s
  defp resolve(?\n, _glyphs), do: ?\n

  defp resolve(char, glyphs) do
    cond do
      Map.has_key?(glyphs, char) -> char
      (base = transliterate(char)) && Map.has_key?(glyphs, base) -> base
      Map.has_key?(glyphs, ??) -> ??
      true -> char
    end
  end

  defp transliterate(char) do
    case [char]
         |> List.to_string()
         |> :unicode.characters_to_nfd_binary()
         |> String.to_charlist() do
      [base | _marks] when base != char -> base
      _ -> nil
    end
  end

  defp feed(?\s, %{wordbreak: -1} = state), do: state
  defp feed(?\n, %{wordbreak: -1} = state), do: %{state | wordbreak: 0}
  defp feed(char, %{wordbreak: -1} = state), do: place(char, %{state | wordbreak: 0})
  defp feed(char, state), do: place(char, state)

  defp place(?\n, state), do: %{print_line(state) | wordbreak: 0}

  defp place(char, state) do
    case add_char(state, char) do
      {:ok, state} -> %{state | wordbreak: wordbreak_after(char, state.wordbreak)}
      {:error, state} -> overflow(char, state)
    end
  end

  defp wordbreak_after(?\s, mode) when mode > 0, do: 2
  defp wordbreak_after(?\s, _mode), do: 0
  defp wordbreak_after(_char, mode) when mode >= 2, do: 3
  defp wordbreak_after(_char, _mode), do: 1

  defp overflow(_char, %{outlinelen: 0} = state) do
    out =
      Enum.reduce(state.glyph, state.out, fn row, out ->
        [out | put_string(oversized_row(row, state), state)]
      end)

    %{state | out: out, wordbreak: -1}
  end

  defp overflow(?\s, state) do
    state = if state.wordbreak == 2, do: split_line(state), else: print_line(state)
    %{state | wordbreak: -1}
  end

  defp overflow(char, state) do
    mode = state.wordbreak
    state = if mode >= 2, do: split_line(state), else: print_line(state)
    place(char, %{state | wordbreak: if(mode == 3, do: 1, else: 0)})
  end

  defp oversized_row(row, %{justification: 2, width: width, limit: limit}) when width > 1,
    do: Enum.take(row, -limit)

  defp oversized_row(row, _state), do: row

  defp finish(%{outlinelen: 0} = state), do: state
  defp finish(state), do: print_line(state)

  defp add_char(state, char) do
    state = get_letter(state, char)
    amount = smush_amount(state)

    if state.outlinelen + state.curr_width - amount > state.limit or
         state.inchr_len + 1 > state.inchr_limit do
      {:error, state}
    else
      rows = Enum.zip_with(state.rows, state.glyph, &merge_row(&1, &2, max(amount, 0), state))

      {:ok,
       %{
         state
         | rows: rows,
           outlinelen: length(hd(rows)),
           inchr: [char | state.inchr],
           inchr_len: state.inchr_len + 1
       }}
    end
  end

  defp get_letter(%{font: font} = state, char) do
    glyph = Map.get(font.glyphs, char) || Map.get(font.glyphs, 0) || empty_rows(font.height)
    %{state | glyph: glyph, prev_width: state.curr_width, curr_width: length(hd(glyph))}
  end

  defp smush_amount(%{font: %{layout: layout}})
       when (layout &&& (@sm_smush ||| @sm_kern)) == 0,
       do: 0

  defp smush_amount(state) do
    state.rows
    |> Enum.zip(state.glyph)
    |> Enum.reduce(state.curr_width, fn {line, char}, acc ->
      min(acc, row_amount(line, char, state))
    end)
  end

  defp row_amount(line, char, %{font: %{right_to_left: 1}} = state) do
    {char_boundary, ch1} = trailing_boundary(char)
    {line_boundary, ch2} = leading_boundary(line)
    bump(line_boundary + state.curr_width - 1 - char_boundary, ch1, ch2, state)
  end

  defp row_amount(line, char, state) do
    {line_boundary, ch1} = trailing_boundary(line)
    {char_boundary, ch2} = leading_boundary(char)
    bump(char_boundary + state.outlinelen - 1 - line_boundary, ch1, ch2, state)
  end

  defp trailing_boundary(row) do
    case row |> Enum.reverse() |> Enum.drop_while(&(&1 == ?\s)) do
      [] -> {0, at(row, 0)}
      [last | _] = trimmed -> {length(trimmed) - 1, last}
    end
  end

  defp leading_boundary(row) do
    spaces = Enum.count(Enum.take_while(row, &(&1 == ?\s)))
    {spaces, at(row, spaces)}
  end

  defp bump(amount, ch1, _ch2, _state) when ch1 in [0, ?\s], do: amount + 1
  defp bump(amount, _ch1, 0, _state), do: amount

  defp bump(amount, ch1, ch2, state) do
    if smushem(ch1, ch2, state) != 0, do: amount + 1, else: amount
  end

  defp merge_row(line, char, amount, %{font: %{right_to_left: 1}} = state) do
    char
    |> smush_into(amount, fn k -> state.curr_width - amount + k end, &at(line, &1), state)
    |> truncate_at_terminator()
    |> Kernel.++(Enum.drop(line, amount))
  end

  defp merge_row(line, char, amount, state) do
    line
    |> smush_into(amount, fn k -> max(state.outlinelen - amount + k, 0) end, &at(char, &1), state)
    |> truncate_at_terminator()
    |> Kernel.++(Enum.drop(char, amount))
  end

  defp smush_into(target, amount, column_for, source_at, state) do
    Enum.reduce(0..(amount - 1)//1, target, fn k, target ->
      column = column_for.(k)
      put(target, column, smushem(at(target, column), source_at.(k), state))
    end)
  end

  defp at(row, index), do: Enum.at(row, index, 0)

  defp put(row, index, value) when index < length(row), do: List.replace_at(row, index, value)
  defp put(row, _index, value), do: row ++ [value]

  defp truncate_at_terminator(row), do: Enum.take_while(row, &(&1 != 0))

  defp smushem(?\s, rch, _state), do: rch
  defp smushem(lch, ?\s, _state), do: lch

  defp smushem(_lch, _rch, %{prev_width: prev, curr_width: curr}) when prev < 2 or curr < 2,
    do: 0

  defp smushem(_lch, _rch, %{font: %{layout: layout}}) when (layout &&& @sm_smush) == 0, do: 0

  defp smushem(lch, rch, %{font: %{layout: layout} = font}) when (layout &&& 63) == 0 do
    cond do
      lch == font.hardblank -> rch
      rch == font.hardblank -> lch
      font.right_to_left == 1 -> lch
      true -> rch
    end
  end

  defp smushem(lch, rch, %{font: %{layout: layout, hardblank: hardblank}}) do
    cond do
      (layout &&& @sm_hardblank) != 0 and lch == hardblank and rch == hardblank -> lch
      lch == hardblank or rch == hardblank -> 0
      (layout &&& @sm_equal) != 0 and lch == rch -> lch
      true -> controlled(lch, rch, layout)
    end
  end

  defp controlled(lch, rch, layout) do
    with nil <- if((layout &&& @sm_lowline) != 0, do: lowline(lch, rch)),
         nil <- if((layout &&& @sm_hierarchy) != 0, do: hierarchy(lch, rch)),
         nil <- if((layout &&& @sm_pair) != 0, do: pair(lch, rch)),
         nil <- if((layout &&& @sm_bigx) != 0, do: bigx(lch, rch)) do
      0
    end
  end

  defp lowline(?_, rch) when rch == 0 or rch in @lowline_set, do: rch
  defp lowline(lch, ?_) when lch == 0 or lch in @lowline_set, do: lch
  defp lowline(_lch, _rch), do: nil

  defp hierarchy(lch, rch) do
    cond do
      lch == ?| and member?(rch, ~c"/\\[]{}()<>") -> rch
      rch == ?| and member?(lch, ~c"/\\[]{}()<>") -> lch
      member?(lch, ~c"/\\") and member?(rch, ~c"[]{}()<>") -> rch
      member?(rch, ~c"/\\") and member?(lch, ~c"[]{}()<>") -> lch
      member?(lch, ~c"[]") and member?(rch, ~c"{}()<>") -> rch
      member?(rch, ~c"[]") and member?(lch, ~c"{}()<>") -> lch
      member?(lch, ~c"{}") and member?(rch, ~c"()<>") -> rch
      member?(rch, ~c"{}") and member?(lch, ~c"()<>") -> lch
      member?(lch, ~c"()") and member?(rch, ~c"<>") -> rch
      member?(rch, ~c"()") and member?(lch, ~c"<>") -> lch
      true -> nil
    end
  end

  defp member?(char, set), do: char == 0 or char in set

  defp pair(lch, rch)
       when {lch, rch} in [{?[, ?]}, {?], ?[}, {?{, ?}}, {?}, ?{}, {?(, ?)}, {?), ?(}],
       do: ?|

  defp pair(_lch, _rch), do: nil

  defp bigx(?/, ?\\), do: ?|
  defp bigx(?\\, ?/), do: ?Y
  defp bigx(?>, ?<), do: ?X
  defp bigx(_lch, _rch), do: nil

  defp print_line(state) do
    out = Enum.reduce(state.rows, state.out, &[&2 | put_string(&1, state)])
    clear_line(%{state | out: out})
  end

  defp clear_line(state) do
    %{state | rows: empty_rows(state.font.height), outlinelen: 0, inchr: [], inchr_len: 0}
  end

  defp split_line(state) do
    {part2, before} = Enum.split_while(state.inchr, &(&1 != ?\s))

    {part1, part2} =
      case before do
        [] -> {[], []}
        _ -> {before |> Enum.drop_while(&(&1 == ?\s)) |> Enum.reverse(), Enum.reverse(part2)}
      end

    state
    |> clear_line()
    |> add_chars(part1)
    |> print_line()
    |> add_chars(part2)
  end

  defp add_chars(state, chars) do
    Enum.reduce(chars, state, fn char, state ->
      {_result, state} = add_char(state, char)
      state
    end)
  end

  defp put_string(row, state) do
    length = if state.width > 1, do: min(length(row), state.width - 1), else: length(row)
    hardblank = state.font.hardblank

    chars =
      row
      |> Enum.take(length)
      |> Enum.map(&if(&1 == hardblank, do: ?\s, else: &1))

    [String.duplicate(" ", padding(length, state)), List.to_string(chars), "\n"]
  end

  defp padding(_length, %{width: width}) when width <= 1, do: 0
  defp padding(_length, %{justification: 0}), do: 0
  defp padding(length, state), do: count_padding(1, length, state.justification, state.width, 0)

  defp count_padding(i, length, justification, width, acc)
       when (3 - justification) * i + length + justification - 2 < width,
       do: count_padding(i + 1, length, justification, width, acc + 1)

  defp count_padding(_i, _length, _justification, _width, acc), do: acc
end
