defmodule Zbar.Mixfile do
  use Mix.Project

  def project do
    [app: :zbar,
     version: "0.1.0",
     description: "Scan one or more barcodes from a JPEG image",
     elixir: "~> 1.4",
     make_clean: ["clean"],
     compilers: [:elixir_make | Mix.compilers()],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:elixir_make] ++ Mix.compilers,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end
end
