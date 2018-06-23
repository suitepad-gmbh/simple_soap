defmodule SimpleSoap.Wsdl.Schema.Type.Sequence do
  import SweetXml
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema
  alias SimpleSoap.Wsdl.Schema.Type.Sequence

  defstruct elements: []

  def parse_value(node, %Sequence{elements: elements}, %Wsdl{} = wsdl) do
    index = 0
    nodes = xpath(node, ~x"./*"l)

    make_list(elements, nodes, 0, [], wsdl)
  end

  defp make_list(elements, nodes, index, result, %Wsdl{} = wsdl) do
    {index, map} = map_elements(elements, nodes, index, %{}, wsdl)
    new_result = result ++ [map]

    cond do
      Enum.count(nodes) > index -> make_list(elements, nodes, index, new_result, wsdl)
      true -> new_result
    end
  end

  defp map_elements([element], nodes, index, result, %Wsdl{} = wsdl) do
    map_element(element, nodes, index, result, wsdl)
  end

  defp map_elements([element | elements], nodes, index, result, %Wsdl{} = wsdl) do
    {new_index, new_result} = map_element(element, nodes, index, result, wsdl)
    map_elements(elements, nodes, new_index, new_result, wsdl)
  end

  defp map_element({key, type}, nodes, index, result, %Wsdl{} = wsdl) do
    {value_node, node_name} =
      case Enum.at(nodes, index) do
        nil ->
          {nil, nil}

        value_node ->
          node_name =
            value_node
            |> Xml.node_local_name()
            |> String.to_atom()

          {value_node, node_name}
      end

    cond do
      is_nil(value_node) ->
        {index, result}

      node_name != key ->
        {index, result}

      true ->
        value = Schema.resolve_with_type(value_node, type, wsdl)
        new_result = Map.put(result, key, value)
        {index + 1, new_result}
    end
  end
end
