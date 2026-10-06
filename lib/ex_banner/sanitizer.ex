defmodule ExBanner.Sanitizer do
  @moduledoc false

  @bidi_controls [0x061C, 0x200E, 0x200F] ++
                   Enum.to_list(0x202A..0x202E) ++ Enum.to_list(0x2066..0x2069)

  @spec strip(binary(), [char()]) :: binary()
  def strip(text, keep \\ []) when is_binary(text) do
    text
    |> String.replace("\r\n", "\n")
    |> String.codepoints()
    |> Enum.filter(&allowed?(&1, keep))
    |> IO.iodata_to_binary()
  end

  @spec control?(integer()) :: boolean()
  def control?(codepoint) when codepoint < 0x20, do: true
  def control?(codepoint) when codepoint in 0x7F..0x9F, do: true
  def control?(codepoint) when codepoint in @bidi_controls, do: true
  def control?(_codepoint), do: false

  defp allowed?(<<codepoint::utf8>>, keep), do: codepoint in keep or not control?(codepoint)
  defp allowed?(_invalid, _keep), do: false
end
