defmodule Mix.Tasks.Tableau.Og.Run do
  use Mix.Task

  @shortdoc "Create the OG images for your site."
  @moduledoc @shortdoc

  @doc false
  def run(_argv) do
    dir = Path.join(:code.priv_dir(:tableau_og_extension), "js")
    {:ok, _} = NodeJS.start_link(path: dir, pool_size: 4)

    config =
      :tableau
      |> Application.get_env(Tableau.OgExtension)
      |> Keyword.put(:run, true)

    Application.put_env(:tableau, Tableau.OgExtension, config)

    Mix.Task.run("tableau.build")
  end
end
