defmodule SimpleSoap.Wsdl.Message do
  import SweetXml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Xml

  defstruct name: nil,
            parts: []

  def read(%Wsdl{doc: doc, xml_schema: xml_schema} = wsdl) do
    xpath(
      doc,
      ~x"/wsdl:definitions/wsdl:message"l
      |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      |> add_namespace("xsd", xml_schema)
    )
    |> Enum.map(fn node -> build_message(node, wsdl) end)
  end

  defp build_message(message_node, %Wsdl{xml_schema: xml_schema}) do
    message_name = Xml.get_attr(message_node, "name", cast_to: :atom)

    parts =
      xpath(
        message_node,
        ~x"./wsdl:part"l
        |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
        |> add_namespace("xsd", xml_schema)
      )
      |> Enum.map(fn node ->
        name = Xml.get_attr(node, "name", cast_to: :atom)

        case {Xml.get_attr(node, "element"), Xml.get_attr(node, "type")} do
          {val, ""} ->
            definition = Wsdl.Helper.resolve_type(val, node)
            %Wsdl.Message.Part{name: name, kind: :element, def: definition}

          {"", val} ->
            definition = Wsdl.Helper.resolve_type(val, node)
            %Wsdl.Message.Part{name: name, kind: :type, def: definition}
        end
      end)

    %__MODULE__{name: message_name, parts: parts}
  end
end
