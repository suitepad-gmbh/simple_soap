defmodule SimpleSoap.Request do
  import SweetXml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Helper
  alias SimpleSoap.Xml
  alias SimpleSoap.Wsdl.PortType
  alias SimpleSoap.Wsdl.PortType.Operation
  alias SimpleSoap.Wsdl.Message
  alias SimpleSoap.Wsdl.Binding

  defstruct operation: nil,
            message: nil,
            params: %{}

  def new(request_body, binding_name, soap_action, %Wsdl{} = wsdl) do
    operation =
      binding_name
      |> get_binding(wsdl)
      |> get_operation(soap_action, wsdl)

    body =
      parse(request_body, namespace_conformant: true)
      |> xpath(
        ~x"/env:Envelope/env:Body"e
        |> add_namespace("env", "http://schemas.xmlsoap.org/soap/envelope/")
      )

    message = get_message(operation, wsdl)
    params = parse_message(message, body, wsdl)
    #
    %__MODULE__{message: message, operation: operation, params: params}
  end

  defp get_binding(name, %Wsdl{bindings: bindings}) do
    Enum.find(bindings, fn %Binding{name: n} -> n == name end)
  end

  defp get_operation(
         %Binding{operations: operations, type: {port_type_namespace, port_type_name}},
         soap_action,
         %Wsdl{port_types: port_types}
       ) do
    port_type = Enum.find(port_types, fn %PortType{name: name} -> name == port_type_name end)

    {_ns, operation_name} = operations[soap_action]
    Enum.find(port_type.operations, fn %Operation{name: n} -> n == operation_name end)
  end

  defp get_message(%Operation{input: {_ns, name}}, %Wsdl{messages: messages}) do
    Enum.find(messages, fn %Message{name: n} -> name == n end)
  end

  #
  # defp match_message(node, %Wsdl{messages: messages}) do
  #   request_types =
  #     xpath(
  #       node,
  #       ~x"./*"l
  #       |> add_namespace("env", "http://schemas.xmlsoap.org/soap/envelope/")
  #     )
  #     |> Enum.map(fn item -> {Xml.namespace_uri(item), Xml.node_local_name(item)} end)
  #     |> Enum.map(fn item -> elem(item, 1) end)
  #     |> Enum.map(&String.to_atom/1)
  #
  #   Enum.find(messages, fn %Wsdl.Message{parts: parts} ->
  #     request_types ==
  #       Enum.map(parts, fn %Wsdl.Message.Part{def: {_ns, type_name}} ->
  #         type_name
  #       end)
  #   end)
  # end

  defp find_operation(port_type_name, node, %Wsdl{port_types: port_types}) do
    %Wsdl.PortType{operations: operations} =
      Enum.find(port_types, fn %Wsdl.PortType{name: name} -> name == port_type_name end)

    operation_name =
      node
      |> Xml.node_local_name()
      |> String.to_atom()

    Enum.find(operations, fn %Wsdl.PortType.Operation{name: name} ->
      name == operation_name
    end)
  end

  defp parse_message(%Wsdl.Message{parts: parts}, operation_node, %Wsdl{} = wsdl) do
    xpath(operation_node, ~x"./*"l)
    |> Enum.reduce(%{}, fn node, acc ->
      temp_name = Xml.node_local_name(node) |> String.to_atom()
      temp_ns = Xml.namespace_uri(node)

      %Wsdl.Message.Part{name: name} =
        Enum.find(parts, fn %Wsdl.Message.Part{def: {_ns, type_name}} ->
          temp_name == type_name
        end)

      value = Helper.typed_value(node, {temp_ns, temp_name}, wsdl)
      Map.put(acc, name, value)
    end)
  end
end
