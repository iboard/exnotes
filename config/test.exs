use Mix.Config

defmodule Exnotes.Config do
  def default_data_dir, do: Path.expand("../data", __DIR__)
end

config :exnotes, 
datadir: System.get_env("EXNOTE_DATA") ||
  Path.join(Exnotes.Config.default_data_dir, "test")
