use Mix.Config

config :exnotes, 
  datadir: System.get_env("EXNOTE_DATA") || Path.join(Exnotes.Config.default_data_dir, "dev")
