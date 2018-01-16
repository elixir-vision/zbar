defmodule Zbar do
  @moduledoc """
  Scan one or more barcodes found in a JPEG image using the zbar library.
  """
  require Logger

  @doc """
  Returns {exit_status, "binary output from zbar_scanner"}
  """
  def scan(filename) do
    {:spawn_executable, zbar_binary()}
    |> Port.open([
      {:args, [filename]},
      :binary,
      :stream,
      :exit_status,
      :use_stdio,
      :stderr_to_stdout
    ])
    |> handle_output()
  end

  defp handle_output(port, buffer \\ "") do
    receive do
      {^port, {:data, data}} ->
        Logger.debug(buffer <> to_string(data))
        handle_output(port, buffer <> to_string(data))
      {^port, {:exit_status, status}} ->
        {status, buffer}
    end
  end

  defp zbar_binary, do: Path.join(:code.priv_dir(:zbar), "zbar_scanner")

end
