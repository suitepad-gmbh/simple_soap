defmodule SimpleSoap.Wsdl.MessageTest do
  use ExUnit.Case

  import WsdlTestHelper
  alias SimpleSoap.Wsdl.Message

  @default_messages """
  <wsdl:message name="Foo" xmlns:ns="http://example.com/types">
    <wsdl:part name="body" element="ns:FooType"/>
  </wsdl:message>
  <wsdl:message name="Bar">
    <wsdl:part name="hello" type="xsd:string"/>
  </wsdl:message>
  <wsdl:message name="Baz">
    <wsdl:part name="hello" type="xsd:string"/>
    <wsdl:part name="times" type="xsd:int"/>
  </wsdl:message>
  """

  test "#read returns a map with messages" do
    assert [
             %Message{
               name: :Foo,
               parts: [
                 %Message.Part{
                   name: :body,
                   kind: :element,
                   def: {:"http://example.com/types", :FooType}
                 }
               ]
             },
             %Message{
               name: :Bar,
               parts: [
                 %Message.Part{
                   name: :hello,
                   kind: :type,
                   def: {:"http://www.w3.org/1999/XMLSchema", :string}
                 }
               ]
             },
             %Message{
               name: :Baz,
               parts: [
                 %Message.Part{
                   name: :hello,
                   kind: :type,
                   def: {:"http://www.w3.org/1999/XMLSchema", :string}
                 },
                 %Message.Part{
                   name: :times,
                   kind: :type,
                   def: {:"http://www.w3.org/1999/XMLSchema", :int}
                 }
               ]
             }
           ] ==
             build_wsdl(@default_messages)
             |> Message.read()
  end
end
