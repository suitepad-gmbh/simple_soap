defmodule SimpleSoap.Xml do
  import SweetXml

  def namespace_uri_for_prefix(node, prefix) do
    prefix = String.to_charlist(prefix)

    node
    |> Tuple.to_list()
    |> List.keyfind(:xmlNamespace, 0)
    |> (fn {:xmlNamespace, _, prefixes} -> prefixes end).()
    |> List.keyfind(prefix, 0)
    |> (fn
          {_, uri} -> uri
          nil -> nil
        end).()
  end

  def namespace_uri(node), do: String.to_atom(xpath(node, ~x"namespace-uri(.)"s))

  def get_attr(node, name, opts \\ [])
  def get_attr(node, name, cast_to: :atom), do: String.to_atom(get_attr(node, name))
  def get_attr(node, name, _), do: xpath(node, ~x"@#{name}"s)

  def node_name(node), do: xpath(node, ~x"name(.)"s)

  def node_local_name(node), do: xpath(node, ~x"local-name(.)"s)

  def text(node), do: xpath(node, ~x"./text()"s)

  def add_soap_namespaces(query) do
    query
    |> SweetXml.add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
    |> SweetXml.add_namespace("xsd", "http://www.w3.org/1999/XMLSchema")
  end
end
