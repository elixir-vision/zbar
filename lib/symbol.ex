defmodule Zbar.Symbol do
  alias __MODULE__

  defstruct [:type, :quality, :points, :data]

  def parse(string) do
    string
    |> String.split(" ")
    |> Enum.reduce(%Symbol{}, fn item, acc ->
      [key, value] = String.split(item, ":", parts: 2)
      case key do
        "type" ->
          %Symbol{acc | type: value}

        "quality" ->
          %Symbol{acc | quality: String.to_integer(value)}

        "points" ->
          %Symbol{acc | points: parse_points(value)}

          "data" ->
            %Symbol{acc | data: Base.decode64!(value)}
      end
    end)
  end

  defp parse_points(string) do
    string
    |> String.split(";")
    |> Enum.map(& parse_point/1)
  end

  defp parse_point(string) do
    [x, y] = String.split(string, ",", parts: 2)
    {String.to_integer(x), String.to_integer(y)}
  end
end
