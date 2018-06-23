defmodule SimpleSoap.WsdlTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl

  describe "snowboard" do
    setup do
      example = File.read!("test/fixtures/snowboard_example/example.wsdl")

      {:ok, %{example: example}}
    end

    test "successfully parses the WSDL file", %{example: example} do
      assert %Wsdl{} = Wsdl.new(example)
    end

    test "parses a request", %{example: example} do
      body = File.read!("test/fixtures/snowboard_example/request.xml")

      assert %SimpleSoap.Request{
               message: %Wsdl.Message{name: :GetEndorsingBoarderRequest},
               operation: %SimpleSoap.Wsdl.PortType.Operation{
                 fault:
                   {:"http://www.snowboard-info.com/EndorsementSearch.wsdl",
                    :GetEndorsingBoarderFault},
                 input:
                   {:"http://www.snowboard-info.com/EndorsementSearch.wsdl",
                    :GetEndorsingBoarderRequest},
                 name: :GetEndorsingBoarder,
                 output:
                   {:"http://www.snowboard-info.com/EndorsementSearch.wsdl",
                    :GetEndorsingBoarderResponse}
               },
               params: %{
                 body: [
                   %{
                     contact: [
                       %{
                         email: "k2@example.com",
                         phone: [%{number: "12345678", prefix: "49", type: "mobile"}]
                       }
                     ],
                     manufacturer: "K2",
                     model: "Fatbob"
                   },
                   %{manufacturer: "K1"},
                   %{manufacturer: "K0", model: "Slimbob"}
                 ]
               }
             } =
               Wsdl.new(example)
               |> Wsdl.parse_request(:GetEndorsingBoarderPortType, body)
    end
  end

  describe "InRoomService" do
    setup do
      example = File.read!("test/fixtures/InRoomService/InRoomService.wsdl")

      {:ok, %{example: example}}
    end

    test "successfully parses the WSDL file", %{example: example} do
      assert %Wsdl{} = Wsdl.new(example)
    end

    test "parses checkIn request", %{example: example} do
      body = File.read!("test/fixtures/InRoomService/checkin.xml")

      assert %SimpleSoap.Request{
               message: %SimpleSoap.Wsdl.Message{
                 name: :checkInInput,
                 parts: [
                   %SimpleSoap.Wsdl.Message.Part{
                     def: {:"http://www.asahotel.com/inroomservice", :checkIn},
                     kind: :element,
                     name: :parameters
                   }
                 ]
               },
               operation: %SimpleSoap.Wsdl.PortType.Operation{
                 fault: nil,
                 input: {:"http://www.asahotel.com/inroomservice", :checkInInput},
                 name: :checkIn,
                 output: {:"http://www.asahotel.com/inroomservice", :checkInOutput}
               },
               params: %{
                 parameters: [
                   %{
                     guest: [
                       %{
                         firstName: "Ursula",
                         language: "de",
                         lastName: "Ackermann",
                         title: "Frau"
                       }
                     ],
                     room: 107,
                     userInfo: [%{clientName: "ie8win7", userName: "Admin"}],
                     viewBill: true
                   }
                 ]
               }
             } =
               Wsdl.new(example, xml_schema: :"http://www.w3.org/2001/XMLSchema")
               |> Wsdl.parse_request(:InRoomServicePortType, body)
    end

    test "parses checkOut request", %{example: example} do
      body = File.read!("test/fixtures/InRoomService/checkout.xml")

      assert %SimpleSoap.Request{
               message: %SimpleSoap.Wsdl.Message{
                 name: :checkOutInput,
                 parts: [
                   %SimpleSoap.Wsdl.Message.Part{
                     def: {:"http://www.asahotel.com/inroomservice", :checkOut},
                     kind: :element,
                     name: :parameters
                   }
                 ]
               },
               operation: %SimpleSoap.Wsdl.PortType.Operation{
                 fault: nil,
                 input: {:"http://www.asahotel.com/inroomservice", :checkOutInput},
                 name: :checkOut,
                 output: {:"http://www.asahotel.com/inroomservice", :checkOutOutput}
               },
               params: %{
                 parameters: [
                   %{
                     room: 107,
                     userInfo: [%{clientName: "ie8win7", userName: "Admin"}]
                   }
                 ]
               }
             } ==
               Wsdl.new(example, xml_schema: :"http://www.w3.org/2001/XMLSchema")
               |> Wsdl.parse_request(:InRoomServicePortType, body)
    end
  end
end
