defmodule SimpleSoap.Wsdl.PortType do
  import SweetXml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Xml

  defstruct operations: %{},
            name: nil,
            namespace: ""

  def read(%Wsdl{doc: doc, xml_schema: xml_schema} = wsdl) do
    xpath(
      doc,
      ~x"/wsdl:definitions/wsdl:portType"l
      |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      |> add_namespace("xsd", xml_schema)
    )
    |> build_list(wsdl)
  end

  defp build_list(nodes, %Wsdl{target_namespace: namespace} = wsdl) do
    Enum.map(nodes, fn port_type_node ->
      name = Xml.get_attr(port_type_node, "name", cast_to: :atom)

      type = build_port_type(port_type_node, wsdl)
      %__MODULE__{type | name: name, namespace: namespace}
    end)
  end

  defp build_port_type(port_type_node, %Wsdl{xml_schema: xml_schema} = wsdl) do
    operations =
      xpath(
        port_type_node,
        ~x"./wsdl:operation"l
        |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
        |> add_namespace("xsd", xml_schema)
      )
      |> Enum.map(fn operation_node ->
        Wsdl.PortType.Operation.build(operation_node, wsdl)
      end)

    %__MODULE__{operations: operations}
  end
end
