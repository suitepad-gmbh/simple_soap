defmodule Example.OmsTest do
  use ExUnit.Case

  alias SimpleSoap.Request
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.PortType.Operation
  import WsdlTestHelper

  setup do
    assert %Wsdl{} =
             wsdl =
             create_wsdl(
               "oms/oms.wsdl",
               xml_schema: :"http://www.w3.org/2001/XMLSchema"
             )

    {:ok, %{wsdl: wsdl}}
  end

  test "used types are parsed properly", %{wsdl: wsdl} do
    assert %Wsdl{types: types} = wsdl
    schema = types.schemas[:"http://tempuri.org/type"]
    assert %Wsdl.Schema{items: items} = schema
    assert %Wsdl.Schema.Type.Sequence{} = items[:Userlist]
    assert %Wsdl.Schema.Type.Sequence{} = items[:OnlineUser]
    assert %Wsdl.Schema.Type.Sequence{} = items[:OfflineUser]
    assert %Wsdl.Schema.Type.Sequence{} = items[:Message]
  end

  # TODO
  # Figure out the reason for the structure of the request message, then make it
  # work
  #
  # test "can make a OMS_CreateUser request", %{wsdl: wsdl} do
  #   assert %Request{operation: operation} =
  #            parse_request(
  #              "oms/OMS_CreateUser.xml",
  #              :OnlineMessengerServiceSoap,
  #              :"http://tempuri.org/action/OMS_CreateUser",
  #              wsdl
  #            )
  #
  #   assert operation.name == :OMS_CreateUser
  # end
  #
  #
  # test "can make a GetCategories request" do
  #   assert %Wsdl{} =
  #            wsdl =
  #            create_wsdl(
  #              "compositions/compositions.wsdl",
  #              xml_schema: :"http://www.w3.org/2001/XMLSchema"
  #            )
  #
  #   assert %Request{operation: operation} =
  #            parse_request(
  #              wsdl,
  #              :AlanBushCompositionsPortType,
  #              "compositions/GetCategories.xml"
  #            )
  #
  #   assert operation.name == :GetCategories
  # end
end
