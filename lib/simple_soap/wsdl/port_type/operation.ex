defmodule SimpleSoap.Wsdl.PortType.Operation do
  import SweetXml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Xml

  defstruct name: nil,
            input: nil,
            output: nil,
            fault: nil

  def build(node, %Wsdl{} = wsdl) do
    name = Xml.get_attr(node, "name", cast_to: :atom)
    input = message_for(node, :input, wsdl)
    output = message_for(node, :output, wsdl)
    fault = message_for(node, :fault, wsdl)

    %__MODULE__{name: name, input: input, output: output, fault: fault}
  end

  defp message_for(operation_node, type, %Wsdl{xml_schema: xml_schema} = wsdl)
       when type in [:input, :output, :fault] do
    case xpath(
           operation_node,
           ~x"./wsdl:#{type}"e
           |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
           |> add_namespace("xsd", xml_schema)
         ) do
      nil ->
        nil

      node ->
        Xml.get_attr(node, "message")
        |> Wsdl.Helper.resolve_type(node)
    end
  end
end
