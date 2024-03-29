defmodule SimpleSoap.Wsdl.Schema.Element do
  import SweetXml
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema
  alias SimpleSoap.Wsdl.Schema.Type

  require Logger

  def nodes(%Wsdl{doc: doc, xml_schema: xml_schema}) do
    xpath(
      doc,
      ~x"/wsdl:definitions/wsdl:types/xsd:schema/xsd:element"l
      |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      |> add_namespace("xsd", xml_schema)
    )
  end

  def type_def(%Wsdl{xml_schema: xml_schema} = wsdl, node) do
    type_ref = Xml.get_attr(node, "type")

    cond do
      type_ref != "" ->
        %Type.Reference{type: Wsdl.Helper.resolve_type(type_ref, node)}

      true ->
        elements = type_elements(wsdl, node)

        case SweetXml.xpath(
               node,
               ~x"local-name(./xsd:complexType/*)"s |> add_namespace("xsd", xml_schema)
             ) do
          "sequence" ->
            %Type.Sequence{elements: elements}

          "all" ->
            %Type.All{elements: elements}

          "simpleContent" ->
            %Type.SimpleContent{elements: elements}

          val ->
            Logger.error("Unknown node type: #{val}")
            nil
        end
    end
  end

  def build_xml(
        type,
        data,
        %Wsdl{xml_schema: xml_schema, types: %SimpleSoap.Wsdl.Types{schemas: schemas}} = wsdl
      ) do
    case type do
      {^xml_schema, _} ->
        Type.Basic.build_xml(type, data, wsdl)

      {namespace, type_name} ->
        %Schema{items: items} = schemas[namespace]
        type = items[type_name]

        case type do
          {_, _} -> build_xml(type, data, wsdl)
          _ -> type.__struct__.build_xml(type, data, wsdl)
        end
    end
  end

  defp type_elements(%Wsdl{xml_schema: xml_schema} = wsdl, node) do
    SweetXml.xpath(node, ~x"./xsd:complexType/*/xsd:element"l |> add_namespace("xsd", xml_schema))
    |> Enum.map(fn item ->
      name = Xml.get_attr(item, "name", cast_to: :atom)

      type =
        Xml.get_attr(item, "type")
        |> Wsdl.Helper.resolve_type(item)

      {name, type}
    end)
  end
end
