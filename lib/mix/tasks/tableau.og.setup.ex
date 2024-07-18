defmodule Mix.Tasks.Tableau.Og.Setup do
  use Mix.Task

  @shortdoc "Sets up the Node dependencies for the OG Extension"
  @moduledoc @shortdoc

  @doc false
  def run(_argv) do
    dir = Path.join(:code.priv_dir(:tableau_og_extension), "js")
    System.cmd("npm", ["install"], cd: dir)
  end
end
