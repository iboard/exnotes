defmodule Exnotes.TUI.App do
  @behaviour Ratatouille.App

  import Ratatouille.View
  import Timewrap, only: [current_time: 0]
  alias Ratatouille.Runtime.Subscription
  alias Ratatouille.Window

  import Ratatouille.Constants, only: [key: 1]

  @delete_keys [key(:delete), key(:backspace), key(:backspace2)]
  @clear key(:ctrl_k)
  @cr key(:enter)
  @up key(:arrow_up)
  @down key(:arrow_down)

  def init(_context) do
    %{
      app_started: current_time(),
      last_update: :never,
      keys: [],
      updates: 0,
      scroll_pos: 0
    }
  end

  def update(model, msg) do
    case msg do
      :tick ->
        %{model | last_update: current_time(), updates: model.updates + 1}

      {:event, %{key: key}} when key in @delete_keys ->
        %{model | keys: Enum.drop(model.keys, 1)}

      {:event, %{key: @clear}} ->
        %{model | keys: []}

      {:event, %{key: @cr}} ->
        %{model | keys: fill_line(model.keys)}

      {:event, %{key: @up}} ->
        %{model | scroll_pos: scroll_up(model.scroll_pos)}

      {:event, %{key: @down}} ->
        %{model | scroll_pos: scroll_down(model.scroll_pos)}

      {:event, %{ch: ch}} ->
        %{
          model
          | last_update: current_time(),
            updates: model.updates + 1,
            keys: [<<ch::utf8>> | model.keys]
        }

      _ ->
        model
    end
  end

  defp scroll_up(pos) when pos > 0, do: pos - 1
  defp scroll_up(pos), do: 0
  defp scroll_down(pos), do: pos + 1

  def fill_line(chars) do
    case rem(Enum.count(chars), width() - 4) do
      0 -> chars
      _ -> fill_line([' ' | chars])
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
    rows =
      ['<' | model.keys]
      |> Enum.reverse()
      |> Enum.chunk_every(width() - 4)
      |> Enum.map(fn l -> to_text(l) end)

    num_lines = Enum.count(rows)
    lines_shown = height()

    view do
      panel title: "ExNotes (CTRL-c to quit)" do
        row do
          column(size: width()) do
            label(content: "Current state:")
            label(content: " ")
            label(content: "      Started: #{model.app_started}")
            label(content: "  Last Update: #{model.last_update}")
            label(content: "      Updates: #{model.updates}")
            label(content: "        Width: #{width()}")

            label(
              content:
                "   Scroll Pos: #{model.scroll_pos} (Showing #{lines_shown} of #{num_lines} lines)"
            )
          end
        end
      end

      panel title: "CTRL-K = clear, CTRL-C = quit" do
        table do
          for r <- rows |> Enum.drop(model.scroll_pos) |> Enum.take(height()) do
            table_row do
              table_cell(content: r)
            end
          end
        end
      end
    end
  end

  defp to_text(chars) do
    chars |> Enum.join()
  end

  def subscribe(_model) do
    Subscription.interval(1, :tick)
  end

  def start_app() do
    Ratatouille.run(Exnotes.TUI.App,
      quit_events: [{:key, Ratatouille.Constants.key(:ctrl_c)}]
    )
  end
end
