defmodule SimpleSoap.Wsdl.Schema.Type.All do
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema
  alias SimpleSoap.Wsdl.Schema.Type.All

  require Logger
  import XmlBuilder

  defstruct elements: []

  def parse_value(_node, %All{}, %Wsdl{}) do
    Logger.error("Complex type 'all' not yet implemented")
    nil
  end

  def build_xml(
        %__MODULE__{elements: elements},
        data,
        %Wsdl{types: %SimpleSoap.Wsdl.Types{schemas: schemas}} = wsdl
      ) do
    Enum.map(elements, fn {key, type} ->
      element(key, %{}, Schema.Element.build_xml(type, Map.get(data, key), wsdl))
    end)
  end
end
