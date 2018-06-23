defmodule SimpleSoap.WsdlTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl

  describe "snowboard" do
    setup do
      example = File.read!("test/fixtures/snowboard_example/example.wsdl")

      {:ok, %{example: example}}
    end

    test "retruns a server struct", %{example: example} do
      assert %Wsdl{} = Wsdl.new(example)
    end

    test "contains the wsdl types", %{example: example} do
      assert %Wsdl{types: types} = Wsdl.new(example)

      assert %{
               Contact: %SimpleSoap.Wsdl.Schema.Type.Sequence{
                 elements: [
                   email: {:"http://www.w3.org/1999/XMLSchema", :string},
                   phone: {:"http://www.w3.org/1999/XMLSchema", :Phone}
                 ]
               },
               GetEndorsingBoarder: %SimpleSoap.Wsdl.Schema.Type.Sequence{
                 elements: [
                   manufacturer: {:"http://www.w3.org/1999/XMLSchema", :string},
                   model: {:"http://www.w3.org/1999/XMLSchema", :string},
                   contact: {:"http://www.w3.org/1999/XMLSchema", :Contact}
                 ]
               },
               GetEndorsingBoarderFault: %SimpleSoap.Wsdl.Schema.Type.All{
                 elements: [
                   errorMessage: {:"http://www.w3.org/1999/XMLSchema", :string}
                 ]
               },
               GetEndorsingBoarderResponse: %SimpleSoap.Wsdl.Schema.Type.All{
                 elements: [
                   endorsingBoarder: {:"http://www.w3.org/1999/XMLSchema", :string}
                 ]
               },
               Phone: %SimpleSoap.Wsdl.Schema.Type.Sequence{
                 elements: [
                   prefix: {:"http://www.w3.org/1999/XMLSchema", :string},
                   type: {:"http://www.w3.org/1999/XMLSchema", :PhoneType},
                   number: {:"http://www.w3.org/1999/XMLSchema", :string}
                 ]
               },
               PhoneType: {:"http://www.w3.org/1999/XMLSchema", :string}
             } = types
    end

    test "contains the messages", %{example: example} do
      assert %Wsdl{messages: messages} = Wsdl.new(example)

      assert [
               %Wsdl.Message{
                 name: :GetEndorsingBoarderRequest,
                 parts: [
                   %Wsdl.Message.Part{
                     name: :body,
                     kind: :element,
                     def:
                       {:"http://schemas.snowboard-info.com/EndorsementSearch.xsd",
                        :GetEndorsingBoarder}
                   }
                 ]
               },
               %Wsdl.Message{
                 name: :GetEndorsingBoarderResponse,
                 parts: [
                   %Wsdl.Message.Part{
                     name: :body,
                     kind: :element,
                     def:
                       {:"http://schemas.snowboard-info.com/EndorsementSearch.xsd",
                        :GetEndorsingBoarderResponse}
                   }
                 ]
               }
             ] = messages
    end

    test "contains port types", %{example: example} do
      assert %Wsdl{port_types: port_types} = Wsdl.new(example)

      assert [
               %SimpleSoap.Wsdl.PortType{
                 name: :GetEndorsingBoarderPortType,
                 namespace: :"http://schemas.xmlsoap.org/wsdl/",
                 operations: [
                   %SimpleSoap.Wsdl.PortType.Operation{
                     name: :GetEndorsingBoarder,
                     fault:
                       {:"http://www.snowboard-info.com/EndorsementSearch.wsdl",
                        :GetEndorsingBoarderFault},
                     input:
                       {:"http://www.snowboard-info.com/EndorsementSearch.wsdl",
                        :GetEndorsingBoarderRequest},
                     output:
                       {:"http://www.snowboard-info.com/EndorsementSearch.wsdl",
                        :GetEndorsingBoarderResponse}
                   }
                 ]
               }
             ] = port_types
    end

    test "parses a request", %{example: example} do
      body = File.read!("test/fixtures/snowboard_example/request.xml")

      assert %SimpleSoap.Operation{
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

    test "retruns a server struct", %{example: example} do
      assert %Wsdl{} = Wsdl.new(example)
    end

    test "contains the messages", %{example: example} do
      assert %Wsdl{messages: messages} =
               Wsdl.new(example, xml_schema: :"http://www.w3.org/2001/XMLSchema")

      assert Enum.member?(
               messages,
               %Wsdl.Message{
                 name: :checkInInput,
                 parts: [
                   %Wsdl.Message.Part{
                     name: :parameters,
                     kind: :element,
                     def: {:"http://www.asahotel.com/inroomservice", :checkIn}
                   }
                 ]
               }
             )
    end

    test "parses checkIn request", %{example: example} do
      body = File.read!("test/fixtures/InRoomService/checkin.xml")

      assert %SimpleSoap.Operation{
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

      assert %SimpleSoap.Operation{
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
