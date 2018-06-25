defmodule SimpleSoap.Wsdl do
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema
  alias SimpleSoap.Wsdl.Types
  alias SimpleSoap.Error.NotImplemented
  import SweetXml

  defstruct doc: nil,
            target_namespace: nil,
            bindings: nil,
            types: nil,
            messages: %{},
            port_types: %{},
            xml_schema: :"http://www.w3.org/1999/XMLSchema"

  def new(data, opts \\ []) do
    doc = parse(data, namespace_conformant: true)

    %__MODULE__{doc: doc}
    |> update_xml_schema(opts)
    |> read_target_namespace
    |> process_types
    |> process_messages
    |> process_port_types
    |> process_bindings
  end

  @doc """
  Takes a parsed WSDL definition and a request body (binary) and parses it. If
  it's successful, a {:ok, %{...}} touple is returned, otherwise
  {:error, reason}. In the success case, the map contains the values of the
  request, parsed into the designated types.
  """
  def parse_request(request_body, binding_name, soap_action, %Wsdl{} = wsdl) do
    SimpleSoap.Request.new(request_body, binding_name, soap_action, wsdl)
  end

  # type could be `output` or `fault`
  def build_response(%Wsdl{}, _type \\ :output, %{} = _params) do
    raise NotImplemented, "Needs to be implemented"
  end

  defp update_xml_schema(%__MODULE__{} = wsdl, xml_schema: xml_schema)
       when is_atom(xml_schema) do
    %__MODULE__{wsdl | xml_schema: xml_schema}
  end

  defp update_xml_schema(%__MODULE__{} = wsdl, _), do: wsdl

  defp read_target_namespace(%__MODULE__{doc: doc} = wsdl) do
    target_namespace =
      xpath(
        doc,
        ~x"/wsdl:definitions/@targetNamespace"s
        |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      )
      |> String.to_atom()

    %__MODULE__{wsdl | target_namespace: target_namespace}
  end

  defp process_types(%__MODULE__{} = wsdl) do
    types = Types.new(wsdl)
    %__MODULE__{wsdl | types: types}
  end

  defp process_messages(%__MODULE__{} = wsdl) do
    messages = Wsdl.Message.read(wsdl)
    %__MODULE__{wsdl | messages: messages}
  end

  defp process_port_types(%__MODULE__{} = wsdl) do
    port_types = Wsdl.PortType.read(wsdl)
    %__MODULE__{wsdl | port_types: port_types}
  end

  defp process_bindings(%__MODULE__{doc: doc} = wsdl) do
    bindings =
      xpath(
        doc,
        ~x"/wsdl:definitions/wsdl:binding"l
        |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      )
      |> Enum.map(&Wsdl.Binding.new(&1, wsdl))

    %__MODULE__{wsdl | bindings: bindings}
  end
end
