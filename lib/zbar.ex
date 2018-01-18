defmodule Zbar do
  @moduledoc """
  Scan all barcodes in a JPEG image using the zbar library.
  """

  alias Zbar.Symbol

  require Logger

  @doc """
  Returns:
    {:ok, [%Zbar.Symbol{}, ...]} on success
    {:error, :timeout} if the zbar process hung for some reason
    {:error, string} if there was an error in the scanning process
  """
  def scan(jpeg_data, timeout \\ 2000) do
    File.open!(temp_file(), [:write, :binary], & IO.binwrite(&1, jpeg_data))
    {:spawn_executable, zbar_binary()}
    |> Port.open([
      {:args, [temp_file()]},
      :binary,
      :stream,
      :exit_status,
      :use_stdio,
      :stderr_to_stdout
    ])
    |> collect_output(timeout)
    |> format_result()
  end

  defp temp_file, do: Path.join(System.tmp_dir!(), "zbar_image.jpg")

  defp zbar_binary, do: Path.join(:code.priv_dir(:zbar), "zbar_scanner")

  defp collect_output(port, timeout, buffer \\ "") do
    receive do
      {^port, {:data, data}} ->
        IO.inspect(Base.encode64(to_string(data)), label: "  <Received")
        collect_output(port, timeout, buffer <> to_string(data))
      {^port, {:exit_status, 0}} ->
        {:ok, buffer}
      {^port, {:exit_status, _}} ->
        {:error, buffer}
    after timeout -> {:error, :timeout}
    end
  end

  defp format_result({:ok, output}) do
    symbols =
      output
      |> String.split("\n", trim: true)
      |> Enum.map(&Symbol.parse/1)
    {:ok, symbols}
  end
  defp format_result({:error, reason}), do: {:error, reason}

end
