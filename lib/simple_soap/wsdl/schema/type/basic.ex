defmodule SimpleSoap.Wsdl.Schema.Type.Basic do
  require Logger

  def build_xml({_, :string}, data, _wsdl) do
    cond do
      is_binary(data) -> data
      true -> inspect(data)
    end
  end

  def build_xml({_, :boolean}, data, _wsdl) do
    case data do
      false -> "false"
      0 -> "false"
      _ -> "true"
    end
  end

  def build_xml({_, :int}, data, _wsdl) do
    "#{data}"
  end

  def build_xml({_, :date}, %Date{} = data, _wsdl) do
    Date.to_iso8601(data)
  end

  def build_xml({_, :date}, _data, _wsdl) do
    ""
  end

  def build_xml(type, data, _wsdl) do
    Logger.error("Unknown type: #{inspect(type)}")
    "#{data}"
  end
end
