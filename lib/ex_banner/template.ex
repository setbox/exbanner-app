defmodule ExBanner.Template do
  @moduledoc false

  alias ExBanner.Colors

  @token ~r/\$\[([a-z0-9_]+)\]|\$([a-z_][a-z0-9_]*)/

  @spec expand(String.t(), %{String.t() => String.t()}, boolean()) ::
          {String.t(), [String.t()]}
  def expand(text, vars, ansi?) when is_binary(text) and is_map(vars) do
    {known, unknown} = colors(text)

    expanded =
      Regex.replace(@token, text, fn
        whole, "", name -> Map.get(vars, name, whole)
        whole, color, _name -> color_sequence(whole, color, ansi?)
      end)

    {reset(expanded, ansi? and known != []), unknown}
  end

  defp color_sequence(whole, color, ansi?) do
    case Colors.lookup(color) do
      {:ok, atom} when ansi? -> Colors.sequence(atom)
      {:ok, _atom} -> ""
      :error -> whole
    end
  end

  defp reset(expanded, true), do: expanded <> Colors.sequence(:reset)
  defp reset(expanded, false), do: expanded

  defp colors(text) do
    @token
    |> Regex.scan(text, capture: :all_but_first)
    |> Enum.flat_map(fn
      [color | _] when color != "" -> [color]
      _ -> []
    end)
    |> Enum.uniq()
    |> Enum.split_with(&match?({:ok, _}, Colors.lookup(&1)))
  end
end
