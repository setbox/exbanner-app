defmodule ExBanner.Error do
  defexception [:reason]

  @impl true
  def message(%__MODULE__{reason: {:unknown_font, font}}), do: "unknown font: #{font}"

  def message(%__MODULE__{reason: {:invalid_font, path, reason}}),
    do: "invalid font #{path}: #{format_reason(reason)}"

  def message(%__MODULE__{reason: {:invalid_width, width}}),
    do: "invalid width: #{inspect(width)}, expected a positive integer"

  def message(%__MODULE__{reason: reason}), do: inspect(reason)

  defp format_reason(:not_a_figlet_font), do: "not a FIGlet font file"
  defp format_reason(:too_large), do: "file too large"
  defp format_reason(reason) when is_atom(reason), do: :file.format_error(reason) |> to_string()
  defp format_reason(reason), do: inspect(reason)
end
