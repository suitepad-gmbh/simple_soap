defmodule SimpleSoap.Wsdl.Helper do
  alias SimpleSoap.Xml

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
end
