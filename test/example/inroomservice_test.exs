defmodule Example.InroomserviceTest do
  use ExUnit.Case

  alias SimpleSoap.Request
  alias SimpleSoap.Response
  alias SimpleSoap.Wsdl
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
               namespace: :"http://www.asahotel.com/inroomservice",
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
               namespace: :"http://www.asahotel.com/inroomservice",
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

  test "builds a response" do
    wsdl =
      create_wsdl(
        "InRoomService/InRoomService.wsdl",
        xml_schema: :"http://www.w3.org/2001/XMLSchema"
      )

    request =
      parse_request(
        "InRoomService/checkin.xml",
        :InRoomServiceSoapBinding,
        :"http://www.asahotel.com/inroomservice/checkIn",
        wsdl
      )

    assert Wsdl.build_response(
             :output,
             %{
               parameters: %{
                 checkInResult: %{
                   success: true,
                   error: "",
                   loginUser: "foo",
                   loginPwd: "bar"
                 }
               }
             },
             request,
             wsdl
           )
           |> Response.to_xml() ==
             """
             <?xml version="1.0" encoding="UTF-8"?>
             <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
               <SOAP-ENV:Body>
                 <m:checkInResponse xmlns:m="http://www.asahotel.com/inroomservice">
                   <checkInResult>
                     <success>true</success>
                     <error></error>
                     <loginUser>foo</loginUser>
                     <loginPwd>bar</loginPwd>
                   </checkInResult>
                 </m:checkInResponse>
               </SOAP-ENV:Body>
             </SOAP-ENV:Envelope>
             """
             |> String.trim()
  end
end
