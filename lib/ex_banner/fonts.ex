defmodule ExBanner.Fonts do
  @moduledoc false

  alias ExBanner.Font

  @extensions [".flf", ".tlf"]

  @fonts_dir Path.expand("../../priv/fonts", __DIR__)
  @external_resource @fonts_dir

  @builtin_files @fonts_dir
                 |> Path.join("*.{flf,tlf}")
                 |> Path.wildcard()
                 |> Map.new(&{Path.rootname(Path.basename(&1)), Path.basename(&1)})

  for {_name, file} <- @builtin_files, do: @external_resource(Path.join(@fonts_dir, file))

  @builtin @builtin_files |> Map.keys() |> Enum.sort() |> Enum.map(&String.to_atom/1)

  @max_size 2_000_000
  @name_pattern ~r/\A[A-Za-z0-9_\-]+\z/

  @spec builtin() :: [atom()]
  def builtin, do: @builtin

  @spec load(atom() | String.t()) :: {:ok, Font.t()} | {:error, term()}
  def load(font) do
    with {:ok, path} <- resolve(font) do
      cached(path)
    end
  end

  defp resolve(font) when is_atom(font) and not is_nil(font) and not is_boolean(font),
    do: resolve_name(Atom.to_string(font))

  defp resolve(font) when is_binary(font) do
    if String.ends_with?(font, @extensions) or String.contains?(font, ["/", "\\"]) do
      resolve_path(font)
    else
      resolve_name(font)
    end
  end

  defp resolve(font), do: {:error, {:unknown_font, inspect(font)}}

  defp resolve_path(path) do
    expanded = Path.expand(path)
    if File.regular?(expanded), do: {:ok, expanded}, else: {:error, {:unknown_font, path}}
  end

  defp resolve_name(name) do
    if Regex.match?(@name_pattern, name) do
      find_in_paths(name) || find_builtin(name) || {:error, {:unknown_font, name}}
    else
      {:error, {:unknown_font, name}}
    end
  end

  defp find_in_paths(name) do
    :exbanner
    |> Application.get_env(:font_paths, [])
    |> Enum.flat_map(fn dir ->
      Enum.map(@extensions, &Path.join(Path.expand(dir), name <> &1))
    end)
    |> Enum.find(&File.regular?/1)
    |> case do
      nil -> nil
      path -> {:ok, path}
    end
  end

  defp find_builtin(name) do
    case Map.fetch(@builtin_files, name) do
      {:ok, file} -> {:ok, Application.app_dir(:exbanner, Path.join(["priv", "fonts", file]))}
      :error -> nil
    end
  end

  defp cached(path) do
    key = {__MODULE__, path}

    case :persistent_term.get(key, nil) do
      nil -> read(path, key)
      font -> {:ok, font}
    end
  end

  defp read(path, key) do
    with {:ok, %File.Stat{size: size}} when size <= @max_size <- File.stat(path),
         {:ok, data} <- File.read(path),
         {:ok, font} <- Font.parse(data) do
      :persistent_term.put(key, font)
      {:ok, font}
    else
      {:ok, %File.Stat{}} -> {:error, {:invalid_font, path, :too_large}}
      {:error, reason} -> {:error, {:invalid_font, path, reason}}
    end
  end
end
