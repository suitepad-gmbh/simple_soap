defmodule SimpleSoap.Wsdl.HelperTest do
  use ExUnit.Case

  import SweetXml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Helper

  @xml """
  <?xml version="1.0" encoding="UTF-8"?>
  <root targetNamespace="http://example.com/targetNamespace" xmlns="http://example.com/root" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:ns="http://example.com/message">
    <foo message="ns:newTermValues"/>
    <bar xmlns:ns="http://example.com/test" message="ns:newTermResult"/>
    <baz message="ns:newTermResult"/>
    <values>
      <string>Hello World!</string>
      <true>1</true>
      <false>0</false>
      <integer>5678</integer>
      <date>2018-07-14</date>
      <PhoneType>
        <case1>phone</case1>
        <case2>mobile</case2>
        <case3>fax</case3>
        <case4>other</case4>
      </PhoneType>
      <Phone>
        <case1>
          <prefix>49</prefix>
          <type>mobile</type>
          <number>12345678</number>
        </case1>
      </Phone>
      <Person>
        <case1>
          <firstname>John</firstname>
          <lastname>Doe</lastname>
        </case1>
      </Person>
    </values>
  </root>
  """

  test "#resolve_type returns a {namespace, type} tuple" do
    xml = parse(@xml, namespace_conformant: true)

    assert Helper.resolve_type("ns:foo", xpath(xml, ~x"foo"e)) ==
             {:"http://example.com/message", :foo}

    assert Helper.resolve_type("ns:bar", xpath(xml, ~x"bar"e)) ==
             {:"http://example.com/test", :bar}

    assert Helper.resolve_type("buzz", xpath(xml, ~x"baz"e)) ==
             {:"http://example.com/root", :buzz}
  end

  test "#typed_value handles primitive types" do
    %Wsdl{xml_schema: schema} =
      wsdl =
      File.read!("test/fixtures/types.wsdl")
      |> Wsdl.new()

    xml = parse(@xml, namespace_conformant: true)

    test_value = fn type, query ->
      Helper.typed_value(xpath(xml, query), type, wsdl)
    end

    assert test_value.({schema, :string}, ~x"values/string"e) == "Hello World!"
    assert test_value.({schema, :boolean}, ~x"values/true"e) == true
    assert test_value.({schema, :boolean}, ~x"values/false"e) == false
    assert test_value.({schema, :int}, ~x"values/integer"e) == 5678
    assert {:ok, test_value.({schema, :date}, ~x"values/date"e)} == Date.new(2018, 7, 14)
    assert test_value.({schema, :unknown}, ~x"values/integer"e) == nil
  end

  test "#typed_value resolves custom types" do
    wsdl =
      File.read!("test/fixtures/types.wsdl")
      |> Wsdl.new()

    xml = parse(@xml, namespace_conformant: true)

    test_value = fn type, query ->
      Helper.typed_value(xpath(xml, query), type, wsdl)
    end

    assert test_value.(
             {:"http://example.com/schemas/objects", :PhoneType},
             ~x"values/PhoneType/case1"e
           ) == "phone"

    assert test_value.({:"http://example.com/schemas/objects", :Person}, ~x"values/Person/case1"e) ==
             nil

    assert test_value.({:"http://example.com/schemas/objects", :Phone}, ~x"values/Phone/case1"e) ==
             [
               %{
                 prefix: 49,
                 type: "mobile",
                 number: "12345678"
               }
             ]
  end
end
