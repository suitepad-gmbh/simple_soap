defmodule SimpleSoap.Wsdl do
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema
  alias SimpleSoap.Error.NotImplemented

  defstruct doc: nil,
            types: %{},
            messages: %{},
            port_types: %{},
            xml_schema: :"http://www.w3.org/1999/XMLSchema"

  def new(data, opts \\ []) do
    doc = SweetXml.parse(data, namespace_conformant: true)

    %__MODULE__{doc: doc}
    |> update_xml_schema(opts)
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
  def parse_request(%Wsdl{} = wsdl, port_type, request_body) do
    SimpleSoap.Operation.new(wsdl, port_type, request_body)
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

  defp process_types(%__MODULE__{} = wsdl) do
    types = Schema.type_def(wsdl)
    %__MODULE__{wsdl | types: types}
  end

  defp process_messages(%__MODULE{} = wsdl) do
    messages = Wsdl.Message.read(wsdl)
    %__MODULE__{wsdl | messages: messages}
  end

  defp process_port_types(%__MODULE{} = wsdl) do
    port_types = Wsdl.PortType.read(wsdl)
    %__MODULE__{wsdl | port_types: port_types}
  end

  defp process_bindings(%__MODULE{} = wsdl), do: wsdl
end
