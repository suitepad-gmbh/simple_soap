defmodule SimpleSoap.ResponseTest do
  use ExUnit.Case

  alias SimpleSoap.Response
  import WsdlTestHelper

  test "Generates a response payload" do
    wsdl = create_wsdl("snowboard/example.wsdl")

    request =
      parse_request(
        "snowboard/GetEndorsingBoarder.xml",
        :EndorsementSearchSoapBinding,
        :"http://www.snowboard-info.com/EndorsementSearch",
        wsdl
      )

    assert Response.new(:output, %{body: %{endorsingBoarder: "Chris Englesmann"}}, request, wsdl)
           |> Response.to_xml() ==
             """
             <?xml version="1.0" encoding="UTF-8"?>
             <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
               <SOAP-ENV:Body>
                 <m:GetEndorsingBoarderResponse xmlns:m="http://namespaces.snowboard-info.com">
                   <endorsingBoarder>Chris Englesmann</endorsingBoarder>
                 </m:GetEndorsingBoarderResponse>
               </SOAP-ENV:Body>
             </SOAP-ENV:Envelope>
             """
             |> String.trim()
  end

  test "Generates a response error payload" do
    wsdl = create_wsdl("snowboard/example.wsdl")

    request =
      parse_request(
        "snowboard/GetEndorsingBoarder.xml",
        :EndorsementSearchSoapBinding,
        :"http://www.snowboard-info.com/EndorsementSearch",
        wsdl
      )

    assert Response.new(:fault, %{body: %{errorMessage: "Some error message"}}, request, wsdl)
           |> Response.to_xml() ==
             """
             <?xml version="1.0" encoding="UTF-8"?>
             <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
               <SOAP-ENV:Body>
                 <m:GetEndorsingBoarderFault xmlns:m="http://namespaces.snowboard-info.com">
                   <errorMessage>Some error message</errorMessage>
                 </m:GetEndorsingBoarderFault>
               </SOAP-ENV:Body>
             </SOAP-ENV:Envelope>
             """
             |> String.trim()
  end
end
