defmodule WsdlTestHelper do
  import SweetXml
  alias SimpleSoap.Wsdl

  def build_wsdl(definition, opts \\ []) do
    data = """
    <?xml version="1.0" encoding="UTF-8"?>
    <wsdl:definitions name="EndorsementSearch" targetNamespace="http://example.com" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:xsd="http://www.w3.org/1999/XMLSchema">
      #{definition}
    </wsdl:definitions>
    """

    doc = parse(data, namespace_conformant: true)
    struct(Wsdl, [{:doc, doc} | opts])
  end

  def load_wsdl(file, opts \\ []) do
    doc =
      File.read!("test/fixtures/#{file}")
      |> parse(namespace_conformant: true)

    struct(Wsdl, [{:doc, doc} | opts])
  end

  def create_wsdl(file, opts \\ []) do
    File.read!("test/fixtures/#{file}")
    |> Wsdl.new(opts)
  end

  def parse_request(filename, binding_name, soap_action, %Wsdl{} = wsdl) do
    data = File.read!("test/fixtures/#{filename}")
    Wsdl.parse_request(data, binding_name, soap_action, wsdl)
  end
end
