defmodule SimpleSoap.Wsdl.Binding do
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Xml
  import SweetXml

  defstruct name: nil,

            # Port type reference
            type: nil,

            # List of mappings from SOAP actions to port type operations
            operations: []

  def new(node, %Wsdl{} = wsdl) do
    name = Xml.get_attr(node, "name", cast_to: :atom)
    type = Xml.get_attr(node, "type") |> Wsdl.Helper.resolve_type(node)
    operations = read_operations(node, wsdl)
    %__MODULE__{name: name, operations: operations, type: type}
  end

  def read_operations(node, %Wsdl{} = wsdl) do
    xpath(
      node,
      ~x"./wsdl:operation"l |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
    )
    |> Enum.map(&build_operation_reference(&1, wsdl))
  end

  def build_operation_reference(node, %Wsdl{target_namespace: target_namespace}) do
    soap_action =
      xpath(
        node,
        ~x"./soap:operation/@soapAction"s
        |> add_namespace("soap", "http://schemas.xmlsoap.org/wsdl/soap/")
      )
      |> String.to_atom()

    name = {target_namespace, Xml.get_attr(node, "name", cast_to: :atom)}

    {soap_action, name}
  end
end
