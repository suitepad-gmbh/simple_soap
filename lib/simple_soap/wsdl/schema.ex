defmodule SimpleSoap.Wsdl.Schema do
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema

  require Logger

  def type_def(%Wsdl{} = wsdl) do
    %{}
    |> Map.merge(type_def_for(Schema.Element, wsdl))
    |> Map.merge(type_def_for(Schema.SimpleType, wsdl))
    |> Map.merge(type_def_for(Schema.ComplexType, wsdl))
  end

  def resolve_with_type(nil, _, %Wsdl{}), do: nil

  def resolve_with_type(_, {:not_found, type}, %Wsdl{}) do
    Logger.error("Type not found: #{inspect(type)}")
    nil
  end

  def resolve_with_type(node, {ns, :string}, %Wsdl{xml_schema: xml_schema})
      when ns == xml_schema do
    Xml.text(node)
  end

  def resolve_with_type(node, {ns, :boolean}, %Wsdl{xml_schema: xml_schema})
      when ns == xml_schema do
    String.to_integer(Xml.text(node)) == 1
  end

  def resolve_with_type(node, {ns, :int}, %Wsdl{xml_schema: xml_schema})
      when ns == xml_schema do
    String.to_integer(Xml.text(node))
  end

  def resolve_with_type(node, {ns, type}, %Wsdl{xml_schema: xml_schema, types: types} = wsdl) do
    type = Map.get(types, type, {:not_found, {ns, type}})
    resolve_with_type(node, type, wsdl)
  end

  def resolve_with_type(node, %Schema.Type.Sequence{} = type, %Wsdl{} = wsdl) do
    Schema.Type.Sequence.parse_value(node, type, wsdl)
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
