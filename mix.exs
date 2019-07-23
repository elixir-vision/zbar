defmodule Zbar.Mixfile do
  use Mix.Project

  def project do
    [
      app: :zbar,
      version: "0.2.0-dev",
      description: "Scan one or more barcodes from a JPEG image",
      elixir: "~> 1.4",
      make_targets: ["all"],
      make_clean: ["clean"],
      compilers: [:elixir_make | Mix.compilers()],
      build_embedded: true,
      start_permanent: Mix.env == :prod,
      compilers: [:elixir_make] ++ Mix.compilers,
      package: package(),
      deps: deps(),
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6", runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end

  defp package() do
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
      links: %{"GitHub" => "https://github.com/GregMefford/zbar-elixir"}
    ]
  end
end
