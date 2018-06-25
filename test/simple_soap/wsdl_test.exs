defmodule SimpleSoap.WsdlTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl
  import WsdlTestHelper

  test "saves the target namespace" do
    assert %Wsdl{target_namespace: target_namespace} = create_wsdl("multiple_bindings.wsdl")
    assert target_namespace == :"http://example.com/methods"
  end

  test "contains a list of all bindings" do
    assert %Wsdl{bindings: bindings} = create_wsdl("multiple_bindings.wsdl")
    assert Enum.count(bindings) == 2
    assert %Wsdl.Binding{} = List.first(bindings)
  end

  #
  # describe "InRoomService" do
  #   setup do
  #     example = File.read!("test/fixtures/InRoomService/InRoomService.wsdl")
  #
  #     {:ok, %{example: example}}
  #   end
  #
  #   test "successfully parses the WSDL file", %{example: example} do
  #     assert %Wsdl{} = Wsdl.new(example)
  #   end
  #
  #   test "parses checkIn request", %{example: example} do
  #     body = File.read!("test/fixtures/InRoomService/checkin.xml")
  #
  #     assert %SimpleSoap.Request{
  #              message: %SimpleSoap.Wsdl.Message{
  #                name: :checkInInput,
  #                parts: [
  #                  %SimpleSoap.Wsdl.Message.Part{
  #                    def: {:"http://www.asahotel.com/inroomservice", :checkIn},
  #                    kind: :element,
  #                    name: :parameters
  #                  }
  #                ]
  #              },
  #              operation: %SimpleSoap.Wsdl.PortType.Operation{
  #                fault: nil,
  #                input: {:"http://www.asahotel.com/inroomservice", :checkInInput},
  #                name: :checkIn,
  #                output: {:"http://www.asahotel.com/inroomservice", :checkInOutput}
  #              },
  #              params: %{
  #                parameters: [
  #                  %{
  #                    guest: [
  #                      %{
  #                        firstName: "Ursula",
  #                        language: "de",
  #                        lastName: "Ackermann",
  #                        title: "Frau"
  #                      }
  #                    ],
  #                    room: 107,
  #                    userInfo: [%{clientName: "ie8win7", userName: "Admin"}],
  #                    viewBill: true
  #                  }
  #                ]
  #              }
  #            } =
  #              Wsdl.new(example, xml_schema: :"http://www.w3.org/2001/XMLSchema")
  #              |> Wsdl.parse_request(:InRoomServicePortType, body)
  #   end
  #
  #   test "parses checkOut request", %{example: example} do
  #     body = File.read!("test/fixtures/InRoomService/checkout.xml")
  #
  #     assert %SimpleSoap.Request{
  #              message: %SimpleSoap.Wsdl.Message{
  #                name: :checkOutInput,
  #                parts: [
  #                  %SimpleSoap.Wsdl.Message.Part{
  #                    def: {:"http://www.asahotel.com/inroomservice", :checkOut},
  #                    kind: :element,
  #                    name: :parameters
  #                  }
  #                ]
  #              },
  #              operation: %SimpleSoap.Wsdl.PortType.Operation{
  #                fault: nil,
  #                input: {:"http://www.asahotel.com/inroomservice", :checkOutInput},
  #                name: :checkOut,
  #                output: {:"http://www.asahotel.com/inroomservice", :checkOutOutput}
  #              },
  #              params: %{
  #                parameters: [
  #                  %{
  #                    room: 107,
  #                    userInfo: [%{clientName: "ie8win7", userName: "Admin"}]
  #                  }
  #                ]
  #              }
  #            } ==
  #              Wsdl.new(example, xml_schema: :"http://www.w3.org/2001/XMLSchema")
  #              |> Wsdl.parse_request(:InRoomServicePortType, body)
  #   end
  # end
end
