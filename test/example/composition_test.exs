defmodule Example.CompositionTest do
  use ExUnit.Case

  alias SimpleSoap.Request
  alias SimpleSoap.Wsdl
  import WsdlTestHelper

  test "used types are parsed properly" do
    assert %Wsdl{types: types} =
             wsdl =
             create_wsdl(
               "compositions/compositions.wsdl",
               xml_schema: :"http://www.w3.org/2001/XMLSchema"
             )

    schema = types.schemas[:"urn:alanbushtrust-org-uk:schemas.objects"]
    assert %Wsdl.Schema{items: items} = schema
    assert %Wsdl.Schema.Type.Reference{} = items[:categories]
    assert %Wsdl.Schema.Type.Sequence{} = items[:"categories-type"]
    assert %Wsdl.Schema.Type.SimpleContent{} = items[:"category-type"]
  end

  test "can make a GetCompositions request" do
    assert %Wsdl{} =
             wsdl =
             create_wsdl(
               "compositions/compositions.wsdl",
               xml_schema: :"http://www.w3.org/2001/XMLSchema"
             )

    assert %Request{params: params} =
             parse_request(
               "compositions/GetCompositions.xml",
               :AlanBushCompositionsSoapBinding,
               :"urn:alanbushtrust-org-uk:soap.methods.GetCompositions",
               wsdl
             )

    assert %{parameters: [%{"category-id": "foo"}]} == params
  end

  test "can make a GetCategories request" do
    assert %Wsdl{} =
             wsdl =
             create_wsdl(
               "compositions/compositions.wsdl",
               xml_schema: :"http://www.w3.org/2001/XMLSchema"
             )

    assert %Request{operation: operation} =
             parse_request(
               "compositions/GetCategories.xml",
               :AlanBushCompositionsSoapBinding,
               :"urn:alanbushtrust-org-uk:soap.methods.GetCategories",
               wsdl
             )

    assert operation.name == :GetCategories
  end
end
