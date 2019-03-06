use Mix.Config

config :exnotes,
  datadir: System.get_env("EXNOTE_DATA") || Path.expand("~/Documents/NOTES/")
