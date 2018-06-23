defmodule SimpleSoap.Wsdl.Schema do
  import SweetXml
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema

  require Logger

  defstruct target_namespace: nil,
            items: []

  def new(parent, %Wsdl{xml_schema: xml_schema} = wsdl) do
    xpath(parent, ~x"./xsd:schema"l |> add_namespace("xsd", xml_schema))
    |> Enum.map(&build(&1, wsdl))
  end

  defp build(node, %Wsdl{xml_schema: xml_schema} = wsdl) do
    target_namespace = Xml.get_attr(node, "targetNamespace", cast_to: :atom)

    items =
      xpath(node, ~x"./xsd:*"l |> add_namespace("xsd", xml_schema))
      |> Enum.map(&process_item(&1, wsdl))

    {target_namespace, %__MODULE__{items: items, target_namespace: target_namespace}}
  end

  defp process_item(item, %Wsdl{} = wsdl) do
    name = Xml.get_attr(item, "name", cast_to: :atom)

    case Xml.node_local_name(item) do
      "element" ->
        {name, Schema.Element.type_def(wsdl, item)}

      "simpleType" ->
        {name, Schema.SimpleType.type_def(wsdl, item)}

      "complexType" ->
        {name, Schema.ComplexType.type_def(wsdl, item)}

      node_name ->
        Logger.error("Type definition not yet supported: #{node_name}")
        nil
    end
  end

  def type_def(%Wsdl{} = wsdl) do
    %{}
    |> Map.merge(type_def_for(Schema.Element, wsdl))
    |> Map.merge(type_def_for(Schema.SimpleType, wsdl))
    |> Map.merge(type_def_for(Schema.ComplexType, wsdl))
  end

  defp type_def_for(type, %Wsdl{} = wsdl) do
    wsdl
    |> type.nodes()
    |> process_type_list(type, wsdl)
  end

  defp process_type_list(list, module, %Wsdl{} = wsdl) do
    Enum.reduce(list, %{}, fn element, acc ->
      name = Xml.get_attr(element, "name", cast_to: :atom)
      def = apply(module, :type_def, [wsdl, element])
      Map.put(acc, name, def)
    end)
  end
end
