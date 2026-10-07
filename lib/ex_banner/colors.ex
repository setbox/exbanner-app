defmodule ExBanner.Colors do
  @moduledoc false

  @styles ~w(reset bright faint italic underline inverse reverse normal not_italic
             no_underline default_color default_background framed encircled overlined
             not_framed_encircled not_overlined)a

  @basic ~w(black red green yellow blue magenta cyan white)a

  @extended Enum.flat_map(Bunt.ANSI.color_tuples(), fn
              {nil, color, _code, _rgb} -> [color]
              {name, color, _code, _rgb} -> [color, String.to_atom(name)]
            end)

  @colors Enum.flat_map(@basic ++ @extended, &[&1, :"#{&1}_background"])

  @names Map.new(@styles ++ @colors, &{Atom.to_string(&1), &1})

  @spec lookup(String.t()) :: {:ok, atom()} | :error
  def lookup(name) when is_binary(name), do: Map.fetch(@names, name)

  @spec valid?(term()) :: boolean()
  def valid?(color) when is_atom(color), do: Map.has_key?(@names, Atom.to_string(color))
  def valid?(_color), do: false

  @spec colorize(String.t(), atom() | nil) :: String.t()
  def colorize(text, nil), do: text

  def colorize(text, color) do
    if valid?(color) do
      [color, text] |> Bunt.ANSI.format() |> IO.iodata_to_binary()
    else
      raise ArgumentError, "unknown color: #{inspect(color)}"
    end
  end

  @spec sequence(atom()) :: String.t()
  def sequence(color) when is_atom(color) do
    [color]
    |> Bunt.ANSI.format_fragment(true)
    |> IO.iodata_to_binary()
  end
end
