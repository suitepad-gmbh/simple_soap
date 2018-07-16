defmodule SimpleSoap.Response do
  alias SimpleSoap.Response
  alias SimpleSoap.Request
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema
  alias SimpleSoap.Wsdl.PortType.Operation
  alias SimpleSoap.Wsdl.Message
  import XmlBuilder

  defstruct xml: nil,
            wsdl: nil

  def new(type, data, %Request{operation: operation}, wsdl) do
    message =
      operation
      |> output_message(type, wsdl)

    xml =
      response_body(message, data, wsdl)
      |> response_envelope()

    %Response{xml: xml, wsdl: wsdl}
  end

  def to_xml(%Response{xml: xml}) do
    document([xml])
    |> generate()
  end

  defp response_envelope(body) do
    element(
      :"SOAP-ENV:Envelope",
      %{"xmlns:SOAP-ENV": "http://schemas.xmlsoap.org/soap/envelope/"},
      [
        element(:"SOAP-ENV:Body", %{}, body)
      ]
    )
  end

  defp response_body(%Message{parts: parts}, data, wsdl) do
    Enum.map(parts, fn part ->
      response_body(part, Map.get(data, part.name), wsdl)
    end)
  end

  defp response_body(
         %Message.Part{def: {namespace, name} = type, kind: :element},
         data,
         %Wsdl{} = wsdl
       ) do
    child = Schema.Element.build_xml(type, data, wsdl)
    element(:"m:#{name}", %{"xmlns:m": namespace}, [child])
  end

  defp output_message(%Operation{output: {_ns, message_name}}, :output, %Wsdl{messages: messages}) do
    Enum.find(messages, fn %Message{name: name} -> message_name == name end)
  end

  defp output_message(%Operation{fault: {_ns, message_name}}, :fault, %Wsdl{messages: messages}) do
    Enum.find(messages, fn %Message{name: name} -> message_name == name end)
  end

  defp output_message(_, _), do: nil
end
