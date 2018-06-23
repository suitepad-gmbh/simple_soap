defmodule SimpleSoap.Operation do
  import SweetXml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Xml

  defstruct operation: nil,
            message: nil,
            params: %{}

  def new(%Wsdl{} = wsdl, port_type, request_body) do
    doc = parse(request_body, namespace_conformant: true)

    body =
      xpath(
        doc,
        ~x"/env:Envelope/env:Body"e
        |> add_namespace("env", "http://schemas.xmlsoap.org/soap/envelope/")
      )

    message = match_message(body, wsdl)
    operation = find_operation(port_type, message, wsdl)
    params = parse_message(message, body, wsdl)

    %__MODULE__{message: message, operation: operation, params: params}
  end

  def match_message(node, %Wsdl{messages: messages}) do
    request_types =
      xpath(
        node,
        ~x"./*"l
        |> add_namespace("env", "http://schemas.xmlsoap.org/soap/envelope/")
      )
      |> Enum.map(fn item -> {Xml.namespace_uri(item), Xml.node_local_name(item)} end)
      |> Enum.map(fn item -> elem(item, 1) end)
      |> Enum.map(&String.to_atom/1)

    Enum.find(messages, fn %Wsdl.Message{parts: parts} ->
      request_types ==
        Enum.map(parts, fn %Wsdl.Message.Part{def: {_ns, type_name}} ->
          type_name
        end)
    end)
  end

  defp find_operation(port_type_name, message, %Wsdl{port_types: port_types}) do
    %Wsdl.PortType{operations: operations} =
      Enum.find(port_types, fn %Wsdl.PortType{name: name} -> name == port_type_name end)

    Enum.find(operations, fn %Wsdl.PortType.Operation{input: input} ->
      case input do
        nil -> false
        {_ns, type} -> type == message.name
      end
    end)
  end

  defp parse_message(%Wsdl.Message{parts: parts}, body, %Wsdl{types: types} = wsdl) do
    xpath(
      body,
      ~x"./*"l
      |> add_namespace("env", "http://schemas.xmlsoap.org/soap/envelope/")
    )
    |> Enum.reduce(%{}, fn node, acc ->
      temp_name =
        Xml.node_local_name(node)
        |> String.to_atom()

      %Wsdl.Message.Part{name: name} =
        Enum.find(parts, fn %Wsdl.Message.Part{def: {_ns, type_name}} ->
          temp_name == type_name
        end)

      type = Map.get(types, temp_name)
      value = type.__struct__.parse_value(node, type, wsdl)
      Map.put(acc, name, value)
    end)
  end
end
