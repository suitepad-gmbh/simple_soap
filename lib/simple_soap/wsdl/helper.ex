defmodule SimpleSoap.Wsdl.Helper do
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema

  require Logger

  def resolve_type(type, node) do
    case String.split(type, ":") do
      [ns, t] ->
        uri = Xml.namespace_uri_for_prefix(node, ns)
        {uri, String.to_atom(t)}

      [t] ->
        uri = Xml.namespace_uri(node)
        {uri, String.to_atom(t)}
    end
  end

  def typed_value(_, {:not_found, type}, %Wsdl{}) do
    Logger.error("Type not found: #{inspect(type)}")
    nil
  end

  def typed_value(_, {:error, message}, %Wsdl{}) do
    Logger.error("Type error: #{message}")
    nil
  end

  def typed_value(node, type, %Wsdl{xml_schema: schema, types: types} = wsdl) do
    case type do
      {^schema, :string} ->
        Xml.text(node)

      {^schema, :boolean} ->
        String.to_integer(Xml.text(node)) == 1

      {^schema, :int} ->
        String.to_integer(Xml.text(node))

      {^schema, _} ->
        new_type = {:not_found, type}
        typed_value(node, new_type, wsdl)

      %Schema.Type.Sequence{} ->
        Schema.Type.Sequence.parse_value(node, type, wsdl)

      %Schema.Type.All{} ->
        Schema.Type.All.parse_value(node, type, wsdl)

      {ns, _type} ->
        new_type = custom_type(List.keyfind(types.schemas, ns, 0), type, wsdl)
        typed_value(node, new_type, wsdl)
    end
  end

  def custom_type(nil, type, _) do
    {:error, "missing namespace #{inspect(type)}"}
  end

  def custom_type({_ns, %Schema{items: items}}, {_, t} = type, _) do
    case List.keyfind(items, t, 0) do
      nil -> {:not_found, type}
      {_, new_type} -> new_type
    end
  end
end
