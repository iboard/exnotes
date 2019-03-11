defmodule Exnotes do
  require Logger
  @moduledoc """
  Documentation for Exnotes.
  """

  @data_path Application.get_env(:exnotes, :datadir)
  def data_path(), do: @data_path

  @doc """
  Get the list of all files.
  Starting at root path of `data_path/0`.
  Sorted by name, including path.

  ### Example

      iex> Exnotes.files()
      ["index.md", "subdir1/index.md", "subdir2/index.md"]

  """
  def files do
    data_path()
    |> files()
    |> relative_paths()
    |> Enum.sort()
  end

  @doc """
  Fetch the tree of files from a given starting directory.
  Returns a list of all files down the directory-structure.

  ### Example

      iex> Path.join(Exnotes.data_path(), "subdir1")
      ...> |> Exnotes.files()
      ...> |> Enum.map( fn f ->
      ...>      Path.relative_to(f,Exnotes.data_path()) 
      ...> end)
      ["subdir1/index.md"]

  """
  def files(path) do
    Files.list_all(path)
  end

  @doc """
  Get a struct of the tree, including meta-informations from
  yaml-top in all files.

  ### Example

      iex> Exnotes.meta()
      [
        %{
          author: "Andi",
          path: "index.md",
          title: "Overall Index"
        },
        %{
          author: "Andi",
          path: "subdir1/index.md",
          title: "Index of subdir 1"
        },
        %{
          author: "Andi",
          path: "subdir2/index.md",
          title: "Index of subdir 2"
        }
      ]

  """
  def meta() do
    files()
    |> Enum.map(&build_meta/1)
  end

  defp build_meta(file) do
    path = Path.join("#{data_path()}", file)

    case File.read(path) do
      {:ok, f} ->
        f
        |> String.split("\n")
        |> read_meta()
        |> build_meta_struct(path)

      {:error, error} ->
        %{ error: error }
    end
  end

  defp build_meta_struct({:ok, meta}, path),
    do: Map.merge(meta, %{path: Path.relative_to(path, data_path())})

  defp build_meta_struct(_, path), do: %{path: Path.relative_to(path, data_path())}

  defp read_meta([first_line | rest]) when first_line == "---" do
    rest
    |> Enum.take_while(fn line -> line != "---" end)
    |> Enum.join("\n")
    |> YamlElixir.read_from_string(atoms: true)
    |> convert_keys()
  end

  defp read_meta(_), do: %{}

  defp relative_paths(list) do
    Enum.map(list, fn item ->
      Path.relative_to(item, data_path())
    end)
  end

  defp convert_keys({:ok, meta}) do
    {:ok, snake_case_map(meta)}
  end

  defp convert_keys(_), do: {:ok, %{}}

  defp snake_case_map(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, result ->
      Map.put(result, String.to_atom(Macro.underscore(key)), snake_case_map(value))
    end)
  end

  defp snake_case_map(list) when is_list(list), do: Enum.map(list, &snake_case_map/1)
  defp snake_case_map(value), do: value
end
