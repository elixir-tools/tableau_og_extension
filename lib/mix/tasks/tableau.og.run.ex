defmodule Mix.Tasks.Tableau.Og.Run do
  use Mix.Task

  @shortdoc "Sets up the Node dependencies for the OG Extension"
  @moduledoc @shortdoc

  @doc false
  def run(_argv) do
    dir = Path.join(:code.priv_dir(:tableau_og_extension), "js")
    {:ok, _} = NodeJS.start_link(path: dir, pool_size: 4)

    Application.put_env(:tableau_og_extension, :run, true)

    Mix.Task.run("tableau.build")
  end
end
