# Exnotes

Playing with the plain terminal and [ratatouille][] by [Nick Reynolds][].

## The Application

The application can read a subdirectory (supposed to have Markdown files in it)
and interpret the YAML-header on top of each file.

## The Terminal App

Currently, when you run `mix run --no-halt`, a simple TUI application will pop up
and you can enter and scroll text. That's all at the moment.

### Plans

  * Read the file-tree through Exnotes and display them in a tree within the TUI.
  * Select a file and show it in a second pane.
  * Select a file and open it in vim ($EDITOR)
  * Add new files (Posts)
  * Export pages to HTML
  * Use CSS templates

## Run the tests

     mix test

## Run the app

     mix run --no-halt



[ratatouille]: https://github.com/ndreynolds/ratatouille
[Nick Reynolds]: https://github.com/ndreynolds
