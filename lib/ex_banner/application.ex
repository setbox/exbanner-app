defmodule ExBanner.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    ExBanner.Startup.run()
    Supervisor.start_link([], strategy: :one_for_one, name: ExBanner.Supervisor)
  end
end
