defmodule Zbar.Symbol do
  defstruct [:type, :data]

  def parse(string) do
    [type, data] = String.split(string, ": ", parts: 2)
    %Zbar.Symbol{
      type: type,
      data: Base.decode64!(data),
    }
  end
end
