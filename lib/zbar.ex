defmodule Zbar do
  @moduledoc """
  Scan all barcodes in a JPEG image using the `zbar` library.
  """

  alias Zbar.Symbol

  require Logger

  @doc """
  Scan all barcode data in a JPEG-encoded image.

  * `jpeg_data` should be a binary containing JPEG-encoded image data.
  * `timeout` is the time in milliseconds to allow for the processing of the image
  (default 5000 milliseconds).

  Returns:
  *  `{:ok, [%Zbar.Symbol{}]}` on success
  *  `{:error, :timeout}` if the zbar process hung for some reason
  *  `{:error, binary()}` if there was an error in the scanning process
  """
  @spec scan(binary(), pos_integer()) ::
          {:ok, list(Zbar.Symbol.t())}
          | {:error, :timeout}
          | {:error, binary()}
  def scan(jpeg_data, timeout \\ 5000) do
    # We run this in a `Task` so that `collect_output` can use `receive`
    # without interfering with the caller's mailbox.
    Task.async(fn -> do_scan(jpeg_data, timeout) end)
    |> Task.await(:infinity)
  end

  @spec do_scan(binary(), pos_integer()) ::
          {:ok, [Zbar.Symbol.t()]}
          | {:error, :timeout}
          | {:error, binary()}
  defp do_scan(jpeg_data, timeout) do
    temp_file = temp_file()
    File.open!(temp_file, [:write, :binary], &IO.binwrite(&1, jpeg_data))

    {:spawn_executable, to_charlist(zbar_binary())}
    |> Port.open([
      {:args, [temp_file]},
      :binary,
      :stream,
      :exit_status,
      :use_stdio,
      :stderr_to_stdout
    ])
    |> collect_output(timeout)
    |> case do
      {:ok, data} ->
        symbols =
          data
          |> String.split("\n", trim: true)
          |> Enum.map(&parse_symbol/1)

        File.rm(temp_file)
        {:ok, symbols}

      {:error, reason} ->
        File.rm(temp_file)
        {:error, reason}
    end
  end

  @spec temp_file() :: binary()
  defp temp_file do
    file = Nanoid.generate() <> ".jpg"
    Path.join(System.tmp_dir!(), file)
  end

  @spec zbar_binary() :: binary()
  defp zbar_binary, do: Path.join(:code.priv_dir(:zbar), "zbar_scanner")

  @spec collect_output(port(), pos_integer(), binary()) ::
          {:ok, binary()}
          | {:error, :timeout}
          | {:error, binary()}
  defp collect_output(port, timeout, buffer \\ "") do
    receive do
      {^port, {:data, "Premature end of JPEG file\n"}} ->
        # Handles an error condition described in https://github.com/elixir-vision/zbar-elixir/issues/1
        collect_output(port, timeout, buffer)

      {^port, {:data, data}} ->
        collect_output(port, timeout, buffer <> to_string(data))

      {^port, {:exit_status, 0}} ->
        {:ok, buffer}

      {^port, {:exit_status, _}} ->
        {:error, buffer}
    after
      timeout ->
        Port.close(port)
        {:error, :timeout}
    end
  end

  # Accepts strings like:
  # type:QR-Code quality:1 points:40,40;40,250;250,250;250,40 data:UkVGMQ==
  #
  # Returns structs like:
  # %Zbar.Symbol{
  #   data: "REF1",
  #   points: [{40, 40}, {40, 250}, {250, 250}, {250, 40}],
  #   quality: 1,
  #   type: "QR-Code"
  # }
  @spec parse_symbol(binary()) :: Zbar.Symbol.t()
  defp parse_symbol(string) do
    string
    |> String.split(" ")
    |> Enum.reduce(%Symbol{}, fn item, acc ->
      case String.split(item, ":", parts: 2) do
        [key, value] ->
          case key do
            "type" ->
              %Symbol{acc | type: parse_type(value)}

            "quality" ->
              %Symbol{acc | quality: String.to_integer(value)}

            "points" ->
              %Symbol{acc | points: parse_points(value)}

            "data" ->
              %Symbol{acc | data: Base.decode64!(value)}

            _ ->
              acc
          end

        _ ->
          acc
      end
    end)
  end

  @spec parse_type(binary()) :: Zbar.Symbol.type_enum()
  defp parse_type("CODE-39"), do: :CODE_39
  defp parse_type("CODE-128"), do: :CODE_128
  defp parse_type("EAN-8"), do: :EAN_8
  defp parse_type("EAN-13"), do: :EAN_13
  defp parse_type("I2/5"), do: :I2_5
  defp parse_type("ISBN-10"), do: :ISBN_10
  defp parse_type("ISBN-13"), do: :ISBN_13
  defp parse_type("PDF417"), do: :PDF417
  defp parse_type("QR-Code"), do: :QR_Code
  defp parse_type("UPC-A"), do: :UPC_A
  defp parse_type("UPC-E"), do: :UPC_E
  defp parse_type(_), do: :UNKNOWN

  @spec parse_points(binary()) :: [Zbar.Symbol.point()]
  defp parse_points(string) do
    string
    |> String.split(";")
    |> Enum.map(&parse_point/1)
  end

  @spec parse_point(binary()) :: Zbar.Symbol.point()
  defp parse_point(string) do
    [x, y] = String.split(string, ",", parts: 2)
    {String.to_integer(x), String.to_integer(y)}
  end
end
