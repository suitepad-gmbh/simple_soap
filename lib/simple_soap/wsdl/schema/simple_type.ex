defmodule SimpleSoap.Wsdl.Schema.SimpleType do
  import SweetXml
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Error.NotImplemented

  def nodes(%Wsdl{doc: doc, xml_schema: xml_schema}) do
    xpath(
      doc,
      ~x"/wsdl:definitions/wsdl:types/xsd:schema/xsd:simpleType"l
      |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      |> add_namespace("xsd", xml_schema)
    )
  end

  def type_def(%Wsdl{xml_schema: xml_schema}, node) do
    case xpath(
           node,
           ~x"./xs:restriction|./xs:union|./xs:list"e |> add_namespace("xs", xml_schema)
         ) do
      nil ->
        {:error, "invalid or missing child element"}

      type_node ->
        type_node
        |> elem(2)
        |> handle_type_node(type_node)
    end
  end

  defp handle_type_node({_, :restriction}, node),
    do: Xml.get_attr(node, "base") |> Wsdl.Helper.resolve_type(node)

  defp handle_type_node({_, type}, _node) do
    raise NotImplemented, message: "simpleType '#{type}' is not yet implemented"
  end
end
