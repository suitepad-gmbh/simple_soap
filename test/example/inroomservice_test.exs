defmodule Example.InroomserviceTest do
  use ExUnit.Case

  alias SimpleSoap.Request
  alias SimpleSoap.Wsdl.Message
  alias SimpleSoap.Wsdl.PortType.Operation
  import WsdlTestHelper

  test "parses checkIn request" do
    wsdl =
      create_wsdl(
        "InRoomService/InRoomService.wsdl",
        xml_schema: :"http://www.w3.org/2001/XMLSchema"
      )

    assert %Request{
             message: %Message{
               name: :checkInInput,
               parts: [
                 %Message.Part{
                   def: {:"http://www.asahotel.com/inroomservice", :checkIn},
                   kind: :element,
                   name: :parameters
                 }
               ]
             },
             operation: %Operation{
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
             parse_request(
               "InRoomService/checkin.xml",
               :InRoomServiceSoapBinding,
               :"http://www.asahotel.com/inroomservice/checkIn",
               wsdl
             )
  end

  test "parses checkOut request" do
    wsdl =
      create_wsdl(
        "InRoomService/InRoomService.wsdl",
        xml_schema: :"http://www.w3.org/2001/XMLSchema"
      )

    assert %Request{
             message: %Message{
               name: :checkOutInput,
               parts: [
                 %Message.Part{
                   def: {:"http://www.asahotel.com/inroomservice", :checkOut},
                   kind: :element,
                   name: :parameters
                 }
               ]
             },
             operation: %Operation{
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
             parse_request(
               "InRoomService/checkout.xml",
               :InRoomServiceSoapBinding,
               :"http://www.asahotel.com/inroomservice/checkOut",
               wsdl
             )
  end
end
