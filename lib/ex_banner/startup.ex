defmodule ExBanner.Startup do
  @moduledoc false

  require Logger

  alias ExBanner.Sanitizer
  alias ExBanner.Template

  @max_size 1_000_000
  @info_line "$app v$version | Elixir $elixir_version | OTP $otp_release\n"

  @spec run() :: :ok
  def run do
    config = Application.get_all_env(:ex_banner)
    mode = Keyword.get(config, :mode, :console)

    with app when is_atom(app) and not is_nil(app) <- Keyword.get(config, :otp_app),
         true <- mode in [:console, :log],
         true <- mix_task_allowed?(Keyword.get(config, :mix_tasks, :all), current_mix_task()) do
      emit(build(app, config, mode), mode)
    else
      _ -> :ok
    end
  rescue
    error ->
      Logger.warning("ExBanner could not print the startup banner: " <> Exception.message(error))
  end

  @spec show() :: :ok
  def show do
    config = Application.get_all_env(:ex_banner)

    app =
      Keyword.get(config, :otp_app) ||
        raise ArgumentError, "ExBanner requires config :ex_banner, otp_app: :my_app"

    mode = if Keyword.get(config, :mode) == :log, do: :log, else: :console
    emit(build(app, config, mode), mode)
  end

  @spec mix_task_allowed?(:all | :none | [String.t()], String.t() | nil) :: boolean()
  def mix_task_allowed?(_setting, nil), do: true
  def mix_task_allowed?(:all, _task), do: true
  def mix_task_allowed?(:none, _task), do: false
  def mix_task_allowed?(tasks, task) when is_list(tasks), do: task in tasks

  @spec mix_task_from_arguments([String.t()]) :: String.t() | nil
  def mix_task_from_arguments(arguments) do
    case Enum.drop_while(arguments, &(Path.basename(&1, ".bat") != "mix")) do
      [_mix, "-" <> _option | _] -> "run"
      [_mix, task | _] -> task
      [_mix] -> "run"
      [] -> nil
    end
  end

  defp current_mix_task do
    if Code.ensure_loaded?(Mix) do
      :init.get_plain_arguments()
      |> Enum.map(&List.to_string/1)
      |> mix_task_from_arguments()
    end
  end

  defp build(app, config, mode) do
    ansi? = mode == :console and Bunt.ANSI.enabled?()
    vars = app |> builtin_vars() |> Map.merge(user_vars(Keyword.get(config, :vars, %{})))

    case read_banner(banner_path(app, Keyword.get(config, :location))) do
      {:ok, text} ->
        expand(text, vars, ansi?)

      :default ->
        ExBanner.render!(Atom.to_string(app), font: :standard) <> expand(@info_line, vars, ansi?)
    end
  end

  defp expand(text, vars, ansi?) do
    {expanded, unknown_colors} = Template.expand(text, vars, ansi?)
    Enum.each(unknown_colors, &Logger.warning("ExBanner ignored unknown color $[#{&1}]"))
    expanded
  end

  defp banner_path(app, nil), do: {:default, Application.app_dir(app, "priv/banner.txt")}

  defp banner_path(_app, {:priv, app, path}),
    do: {:custom, Application.app_dir(app, Path.join("priv", path))}

  defp banner_path(_app, path) when is_binary(path), do: {:custom, path}

  defp read_banner({origin, path}) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular, size: size}} when size <= @max_size ->
        {:ok, path |> File.read!() |> Sanitizer.strip([?\n, ?\t])}

      {:ok, %File.Stat{type: :regular}} ->
        Logger.warning("ExBanner ignored #{path}: file too large")
        :default

      _ when origin == :custom ->
        Logger.warning("ExBanner could not find #{path}, using the default banner")
        :default

      _ ->
        :default
    end
  end

  defp builtin_vars(app) do
    %{
      "app" => Atom.to_string(app),
      "version" => spec(app, :vsn),
      "description" => spec(app, :description),
      "elixir_version" => System.version(),
      "otp_release" => System.otp_release(),
      "ex_banner_version" => spec(:ex_banner, :vsn),
      "node" => Atom.to_string(node()),
      "hostname" => hostname(),
      "release" => System.get_env("RELEASE_NAME", ""),
      "schedulers" => Integer.to_string(System.schedulers_online())
    }
    |> Map.new(fn {name, value} -> {name, Sanitizer.strip(value)} end)
  end

  defp spec(app, key), do: app |> Application.spec(key) |> Kernel.||(~c"") |> to_string()

  defp hostname do
    {:ok, name} = :inet.gethostname()
    List.to_string(name)
  end

  defp user_vars({module, function, args}), do: user_vars(apply(module, function, args))

  defp user_vars(vars) when is_map(vars) or is_list(vars) do
    Map.new(vars, fn {name, value} -> {to_string(name), Sanitizer.strip(stringify(value))} end)
  end

  defp stringify(value) when is_binary(value), do: value
  defp stringify(value) when is_atom(value) or is_number(value), do: to_string(value)
  defp stringify(value), do: inspect(value)

  defp emit(text, :log), do: Logger.info(text)
  defp emit(text, :console), do: IO.write(ensure_newline(text))

  defp ensure_newline(text) do
    if String.ends_with?(text, "\n"), do: text, else: text <> "\n"
  end
end
