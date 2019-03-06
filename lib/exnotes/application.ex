defmodule Exnotes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = []

    unless Mix.env() == :test do
      spawn(fn ->
        Exnotes.TUI.App.start_app()
      end)
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exnotes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
