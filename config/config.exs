use Mix.Config

defmodule Exnotes.Config do
  def default_data_dir, do: Path.expand("../data", __DIR__)
end

import_config "#{Mix.env()}.exs"
