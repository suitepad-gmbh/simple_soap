# SimpleSoap

A library for parsing and building SOAP bodies based on a WSDL file, written in Elixir.

## WARNING

**This library is not production ready and has some fundamental issues**

Please check the [issues](https://github.com/suitepad-gmbh/simple_soap/issues)
for more details.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `simple_soap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simple_soap, "~> 0.1.0"}
  ]
end
```

## Usage

### Parsing requests

```elixir
wsdl_file = File.read!("test/fixtures/InRoomService/InRoomService.wsdl")
wsdl = SimpleSoap.Wsdl.new(wsdl_file, xml_schema: :"http://www.w3.org/2001/XMLSchema")

checkin_request = File.read!("test/fixtures/InRoomService/checkin.xml")
SimpleSoap.Wsdl.parse_request(wsdl, :InRoomServicePortType, checkin_request)
```

The last command will return an operation struct, containing information about
the SOAP operation to execute, and the parameters given with the request.

```elixir
%SimpleSoap.Request{
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
}
```

### Building a response

```elixir
data = %{
  parameters: %{
    checkInResult: %{
      success: true,
      error: "",
      loginUser: "foo",
      loginPwd: "bar"
    }
  }
}
SimpleSoap.Wsdl.build_response(:output, data, request, wsdl)
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Body>
    <m:checkInOutput xmlns:m="http://www.asahotel.com/inroomservice">
      <checkInResult>
        <success>true</success>
        <error></error>
        <loginUser>foo</loginUser>
        <loginPwd>bar</loginPwd>
      </checkInResult>
    </m:checkInOutput>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
```
