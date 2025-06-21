defmodule Tableau.OgExtension do
  @moduledoc ~S'''
  Extension to create Open Graph images.

  The Open Graph extension utilizes a user provided template, the Puppeteer Node.js module, and Google Chrome to 
  create screenshots. So, you must have Node.js and Google Chrome installed on your system.

  These screenshots are saved to the filesystem and it's up to the user to utilize them however they'd wish.

  You can keep them inside git and serve them through your CDN or upload them to something like AWS S3.

  This extension is not responsible for setting the relevant HTML tags in your document to actually utilize the
  images.

  Images are named based on the permalink of the the page, with the root page being named `root.png`.

  ## Setup

  Before using this extension, you must ensure you have Node.js and Google Chrome installed locally.

  Then you can run the Mix Task `mix tableau.og.setup` and it will install the appropriate NPM packages.

  ## Usage

  The extension is ran when you run the Mix Task `mix tableau.og.run`.

  Subsequent runs will not regenerate existing images, so delete them first if you have changed your template.

  ### Template

  The extension will render a configured template into the image. The template is configured as a module/function tuple
  that will be passed assigns including the Tableau page, which includes the title, permalink, etc.

  Here is an example:

  ```elixir
  defmodule MySite.Og do
    require EEx
    EEx.function_from_string(
      :def,
      :template,
      """
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <meta charset="utf-8" />
          <style>
           <!-- my styles -->
          </style>
        </head>
        <body >
          <%= @page.title %> 
        </body>
      </html>
      """,
      [:assigns]
    )
  end
  ```

  Configuration example can be seen below.

  ## Configuration

  Examples are shown below.

  ```elixir
  # config/config.exs

  config :tableau, Tableau.OgExtension,
    enabled: true,
    path: "./priv/og",
    template: {MySite.Og, :template}
    log: true
  ```
  '''
  use Tableau.Extension,
    enabled: true,
    key: :og,
    priority: 300

  import Schematic

  @impl Tableau.Extension
  def config(config) do
    unify(
      map(%{
        optional(:run, false) => bool(),
        optional(:path, "priv/og") => str(),
        optional(:log, true) => bool(),
        template: tuple([atom(), atom()])
      }),
      config
    )
  end

  @doc false
  @impl Tableau.Extension
  def pre_write(token) do
    %{extensions: %{og: %{config: config}}} = token

    if config.run do
      {template_module, template_function} = config[:template]

      token.site.pages
      |> Task.async_stream(
        fn page ->
          if page[:title] do
            file = file_name(page[:permalink])
            path = config[:path] |> Path.join(file)

            unless File.exists?(path) do
              html = apply(template_module, template_function, [%{page: page}])

              image =
                "take-screenshot"
                |> NodeJS.call!([html], binary: true)
                |> Base.decode64!()

              File.mkdir_p!(path |> Path.dirname())
              File.write!(path, image)

              if config[:log] do
                Mix.shell().info("==> created image for #{page.permalink} at #{path}")
              end
            end
          end
        end,
        timeout: :infinity
      )
      |> Stream.run()
    end

    {:ok, token}
  end

  @doc """
  Returns the file name based on a permalink.
  """
  def file_name(permalink) do
    with ".png" <- String.trim_trailing(permalink, "/") <> ".png" do
      "root.png"
    end
  end
end
