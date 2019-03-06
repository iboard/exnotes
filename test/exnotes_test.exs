defmodule ExnotesTest do
  use ExUnit.Case
  doctest Exnotes

  test "Read data-path from config" do
    assert Application.get_env(:exnotes, :datadir) =~ ~r{/exnotes/data/test$}
  end

  test "Read directory-tree" do
    tree = Exnotes.tree()

    assert ["index.md", "subdir1/index.md", "subdir2/index.md"] == tree
  end

  test "Read tree with meta-data" do
    assert [
             %{author: "Andi", path: "index.md", title: "Overall Index"},
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
           ] == Exnotes.meta_tree()
  end
end
