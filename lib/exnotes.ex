defmodule Exnotes do
  @moduledoc """
  Documentation for Exnotes.
  """

  @doc """
  Return data root path from config
  """
  def data_path, do: Application.get_env(:exnotes, :datadir)
  def data_path(:relative), do: "."

  @doc """
  Get the tree starting at root path
  """
  def tree do
    data_path()
    |> tree()
    |> relative_paths()
    |> Enum.sort()
  end

  def tree(path) do
    case File.dir?(path) do
      false ->
        [path]

      true ->
        File.ls!(path)
        |> Enum.reduce([], fn i, acc ->
          p = Path.join(path, i)

          case File.dir?(p) do
            false -> [p | acc]
            true -> [tree(p) | acc]
          end
        end)
    end
  end

  def meta_tree() do
    tree()
    |> Enum.map(fn file ->
      build_meta(file)
    end)
  end

  defp build_meta(file) do
    path = Path.join(data_path(), file)

    {:ok, meta} =
      File.read!(path)
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.take_while(fn x -> x != "---" end)
      |> Enum.join("\n")
      |> YamlElixir.read_from_string()

    %{
      path: Path.relative_to(path, data_path()),
      title: meta["title"],
      author: meta["author"]
    }
  end

  defp relative_paths(list) do
    Enum.map(list, fn item ->
      Path.relative_to(item, data_path())
    end)
  end
end
