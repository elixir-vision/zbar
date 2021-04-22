defmodule Zbar.Mixfile do
  use Mix.Project

  def project do
    [
      app: :zbar,
      version: "0.2.1",
      description: "Scan one or more barcodes from a JPEG image",
      elixir: "~> 1.4",
      make_targets: ["all"],
      make_clean: ["clean"],
      compilers: [:elixir_make | Mix.compilers()],
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      package: package(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6", runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:nanoid, "~> 2.0.5", runtime: false}
    ]
  end

  defp docs do
    [
      main: "README",
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "src/*.[ch]",
        "Makefile",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      maintainers: ["Greg Mefford"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elixir-vision/zbar-elixir"}
    ]
  end
end
