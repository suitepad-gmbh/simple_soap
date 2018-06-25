defmodule Example.SnowboardTest do
  use ExUnit.Case

  alias SimpleSoap.Request
  alias SimpleSoap.Wsdl
  import WsdlTestHelper

  test "used types are detected properly" do
    assert %Wsdl{types: types} = wsdl = create_wsdl("snowboard/example.wsdl")

    schema = types.schemas[:"http://namespaces.snowboard-info.com"]
    assert %Wsdl.Schema{items: items} = schema
    assert items[:PhoneType] == {:"http://www.w3.org/1999/XMLSchema", :string}
    assert %Wsdl.Schema.Type.Sequence{} = items[:Phone]
    assert %Wsdl.Schema.Type.All{} = items[:GetEndorsingBoarderResponse]
  end

  test "can make a GetEndorsingBoarder request" do
    assert %Wsdl{} = wsdl = create_wsdl("snowboard/example.wsdl")

    assert %Request{params: params} =
             parse_request(
               "snowboard/GetEndorsingBoarder.xml",
               :EndorsementSearchSoapBinding,
               :"http://www.snowboard-info.com/EndorsementSearch",
               wsdl
             )

    assert params == %{
             body: [
               %{
                 manufacturer: "K2",
                 model: "Fatbob",
                 contact: [
                   %{
                     email: "k2@example.com",
                     phone: [%{prefix: 49, type: "mobile", number: "12345678"}]
                   }
                 ]
               },
               %{manufacturer: "K1"},
               %{manufacturer: "K0", model: "Slimbob"}
             ]
           }
  end
end
