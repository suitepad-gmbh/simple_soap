defmodule SimpleSoap.Wsdl.Schema.ComplexType do
  import SweetXml
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema.Type

  require Logger

  def nodes(%Wsdl{doc: doc, xml_schema: xml_schema}) do
    xpath(
      doc,
      ~x"/wsdl:definitions/wsdl:types/xsd:schema/xsd:complexType"l
      |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      |> add_namespace("xsd", xml_schema)
    )
  end

  def type_def(%Wsdl{} = wsdl, node) do
    case xpath(node, ~x"local-name(./*)"s) do
      "sequence" ->
        elements = type_elements(wsdl, node)
        %Type.Sequence{elements: elements}

      "all" ->
        elements = type_elements(wsdl, node)
        %Type.All{elements: elements}

      "simpleContent" ->
        %Type.SimpleContent{elements: []}

      val ->
        Logger.error("Unknown node type: #{val}")
        nil
    end
  end

  defp type_elements(%Wsdl{xml_schema: xml_schema}, node) do
    xpath(node, ~x"./*/xsd:element"l |> add_namespace("xsd", xml_schema))
    |> Enum.map(fn item ->
      name = Xml.get_attr(item, "name", cast_to: :atom)

      type =
        Xml.get_attr(item, "type")
        |> Wsdl.Helper.resolve_type(item)

      {name, type}
    end)
  end
end
