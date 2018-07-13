defmodule SimpleSoap.Wsdl.Schema.ElementTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl.Schema.Element
  import WsdlTestHelper
  import XmlBuilder

  test "#build_xml serializes primitive types" do
    wsdl = create_wsdl("types.wsdl")

    assert Element.build_xml({wsdl.xml_schema, :string}, "Hello World", wsdl)
           |> generate() == "Hello World"

    assert Element.build_xml({wsdl.xml_schema, :int}, 5, wsdl)
           |> generate() == "5"

    assert Element.build_xml({wsdl.xml_schema, :boolean}, true, wsdl)
           |> generate() == "true"

    assert Element.build_xml({wsdl.xml_schema, :boolean}, 1, wsdl)
           |> generate() == "true"

    assert Element.build_xml({wsdl.xml_schema, :boolean}, false, wsdl)
           |> generate() == "false"

    assert Element.build_xml({wsdl.xml_schema, :boolean}, 0, wsdl)
           |> generate() == "false"

    {:ok, date} = Date.new(2018, 7, 14)

    assert Element.build_xml({wsdl.xml_schema, :date}, date, wsdl)
           |> generate() == "2018-07-14"

    assert Element.build_xml({wsdl.xml_schema, :date}, nil, wsdl)
           |> generate() == ""
  end

  test "#build_xml creates the XML for a complex 'all' type" do
    wsdl = create_wsdl("types.wsdl")

    assert Element.build_xml(
             {:"http://example.com/schemas/objects", :Person},
             %{
               firstname: "John",
               lastname: "Doe"
             },
             wsdl
           )
           |> generate(format: :none) == "<firstname>John</firstname><lastname>Doe</lastname>"
  end

  test "#build_xml creates the XML for a complex referenced 'sequence' type with a hash" do
    wsdl = create_wsdl("types.wsdl")

    assert Element.build_xml(
             {:"http://example.com/schemas/objects", :Telephone},
             %{
               prefix: 49,
               type: "phone",
               number: "0000000"
             },
             wsdl
           )
           |> generate(format: :none) ==
             "<prefix>49</prefix><type>phone</type><number>0000000</number>"
  end

  test "#build_xml creates the XML for a complex 'sequence' type with a list" do
    wsdl = create_wsdl("types.wsdl")

    assert Element.build_xml(
             {:"http://example.com/schemas/objects", :Telephone},
             [
               %{
                 prefix: 49,
                 type: "phone",
                 number: "0000000"
               },
               %{
                 prefix: 49,
                 type: "mobile",
                 number: "11111111"
               }
             ],
             wsdl
           )
           |> generate(format: :none) ==
             "<prefix>49</prefix><type>phone</type><number>0000000</number><prefix>49</prefix><type>mobile</type><number>11111111</number>"
  end
end
