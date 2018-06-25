defmodule SimpleSoap.Wsdl.PortTypeTest do
  use ExUnit.Case

  import WsdlTestHelper
  alias SimpleSoap.Wsdl.PortType

  @default_port_type """
  <wsdl:portType name="glossaryTerms" xmlns:ns="http://example.com/message">
    <wsdl:operation name="setTerm">
      <wsdl:input message="ns:newTermValues"/>
      <wsdl:output message="ns:newTermResult"/>
    </wsdl:operation>
  </wsdl:portType>
  """

  test "#read returns a port type map" do
    assert [
             %PortType{
               name: :glossaryTerms,
               namespace: :"http://example.com/targetNamespace",
               operations: [
                 %PortType.Operation{
                   name: :setTerm,
                   input: {:"http://example.com/message", :newTermValues},
                   output: {:"http://example.com/message", :newTermResult},
                   fault: nil
                 }
               ]
             }
           ] ==
             build_wsdl(
               @default_port_type,
               target_namespace: :"http://example.com/targetNamespace"
             )
             |> PortType.read()
  end
end
