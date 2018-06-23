defmodule WsdlTestHelper do
  import SweetXml
  alias SimpleSoap.Wsdl

  def build_wsdl(definition) do
    data = """
    <?xml version="1.0" encoding="UTF-8"?>
    <wsdl:definitions name="EndorsementSearch" targetNamespace="http://example.com" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:xsd="http://www.w3.org/1999/XMLSchema">
      #{definition}
    </wsdl:definitions>
    """

    doc = parse(data, namespace_conformant: true)
    %Wsdl{doc: doc, xml_schema: "http://www.w3.org/1999/XMLSchema"}
  end
end
