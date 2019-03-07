defmodule Exnotes.TUI.App do
  @behaviour Ratatouille.App

  import Ratatouille.View
  import Timewrap, only: [current_time: 0]
  alias Ratatouille.Runtime.Subscription
  alias Ratatouille.Window

  import Ratatouille.Constants, only: [key: 1, attribute: 1, color: 1]

  @delete_keys [key(:delete), key(:backspace), key(:backspace2)]
  @clear key(:ctrl_k)
  @cr key(:enter)
  @up key(:arrow_up)
  @down key(:arrow_down)

  @bold attribute(:bold)
  @style_selected [
    color: color(:black),
    background: color(:cyan)
  ]

  def init(_context) do
    %{
      app_started: current_time(),
      last_update: :never,
      files: Exnotes.meta(),
      selected_row: 0,
      updates: 0,
      scroll_pos: 0,
      selected_file: nil
    }
  end

  def update(model, msg) do
    case msg do
      :tick ->
        %{model | last_update: current_time(), updates: model.updates + 1}

      {:event, %{key: key}} when key in @delete_keys ->
        model

      {:event, %{key: @clear}} ->
        model

      {:event, %{key: @cr}} ->
        %{model | selected_file: model.files |> Enum.at(model.selected_row)}

      {:event, %{key: @up}} ->
        %{model | scroll_pos: scroll_up(model.scroll_pos)}

      {:event, %{key: @down}} ->
        %{model | scroll_pos: scroll_down(model.scroll_pos)}

      {:event, %{ch: ?j}} ->
        %{model | selected_row: selected_row(model, :inc)}

      {:event, %{ch: ?k}} ->
        %{model | selected_row: selected_row(model, :dec)}

      {:event, %{ch: ch}} ->
        model

      _ ->
        model
    end
  end

  defp read_current_file(%{selected_file: nil}), do: []
  defp read_current_file(%{selected_file: meta}) do
    Path.join(Exnotes.data_path(), meta.path)
    |> File.read!
    |> String.split("\n")
  end

  defp selected_row(model, :inc) do
    min(model.selected_row + 1, Enum.count(model.files) - 1)
  end

  defp selected_row(model, :dec) do
    max(model.selected_row - 1, 0)
  end

  defp scroll_up(pos) when pos > 0, do: pos - 1
  defp scroll_up(_pos), do: 0
  defp scroll_down(pos), do: pos + 1

  defp selected_attr(model, current_row) do
    cond do
      Enum.at(model.files, model.selected_row) == current_row -> @style_selected
      true -> []
    end
  end

  defp width() do
    {:ok, w} = Window.fetch(:width)
    w
  end

  defp height() do
    {:ok, h} = Window.fetch(:height)
    h - 12
  end

  def render(model) do
    num_lines = Enum.count(model.files)
    lines_shown = height()

    view do
      panel title: "ExNotes ([q]uit)" do
        row do
          column(size: width()) do
            label(content: "      Started: #{model.app_started}")
            label(content: "  Last Update: #{model.last_update}")
            label(content: "      Updates: #{model.updates}")
            label(content: " Width/Height: #{width()}x#{height()}")

            label(
              content:
                "   Scroll Pos: #{model.scroll_pos} (Showing #{lines_shown} of #{num_lines} lines)"
            )

            label(content: " Selected Row: #{model.selected_row}")
          end
        end
      end

      row do
        column size: 4 do
          panel title: "Files (j=down, k=up, ENTER=select)", height: :fill do
            table do
              table_row attributes: [@bold] do
                table_cell(content: "Title")
                table_cell(content: "Author")
                table_cell(content: "File")
              end

              for r <- model.files |> Enum.drop(model.scroll_pos) |> Enum.take(height()) do
                table_row(selected_attr(model, r)) do
                  table_cell(content: r.title)
                  table_cell(content: r.author)
                  table_cell(content: r.path)
                end
              end
            end
          end
        end

        column size: 8 do
          panel title: "<#{file_title(model)}>" do
            for line <- file_content(model) |> String.split("\n") do
              label do
                text(content: line)
              end
            end
          end

          panel title: "<#{file_title(model)}>", height: :fill do
            for line <- read_current_file(model) do
              label do
                text(content: line)
              end
            end
          end
        end
      end
    end
  end

  defp file_title(%{selected_file: nil}), do: "NO FILE SELECTED"
  defp file_title(%{selected_file: file}), do: file.title || "no title"
  defp file_content(%{selected_file: nil}), do: "select a file on the left side and press <ENTER>"
  defp file_content(%{selected_file: file}), do: inspect(file, pretty: true)

  def subscribe(_model) do
    Subscription.interval(1, :tick)
  end

  def start_app(_) do
    # pid = spawn Ratatouille, :run, [Exnotes.TUI.App, []]
    # quit_events: [{:char, ?q}]
    unless Mix.env == :test do
      Ratatouille.run(__MODULE__, [])
    end
    {:ok, self()}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_app, [opts]},
      type: :worker,
      restart: :temporary,
      shutdown: 500
    }
  end
end
