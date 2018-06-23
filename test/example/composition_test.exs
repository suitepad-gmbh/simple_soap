defmodule Example.CompositionTest do
  use ExUnit.Case
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Request
  import WsdlTestHelper
  #
  # test "sdf" do
  #   assert %Wsdl{types: types} =
  #            wsdl =
  #            create_wsdl(
  #              "compositions/compositions.wsdl",
  #              xml_schema: :"http://www.w3.org/2001/XMLSchema"
  #            )
  #
  #   schema = types.schemas[:"urn:alanbushtrust-org-uk:schemas.objects"]
  #   assert %Wsdl.Schema{items: items} = schema
  #   IO.inspect(items)
  # end

  test "can make a GetCompositions request" do
    assert %Wsdl{} =
             wsdl =
             create_wsdl(
               "compositions/compositions.wsdl",
               xml_schema: :"http://www.w3.org/2001/XMLSchema"
             )

    assert %Request{params: params} =
             parse_request(
               wsdl,
               :AlanBushCompositionsPortType,
               "compositions/GetCompositions.xml"
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
               wsdl,
               :AlanBushCompositionsPortType,
               "compositions/GetCategories.xml"
             )

    assert operation.name == :GetCategories
  end
end
