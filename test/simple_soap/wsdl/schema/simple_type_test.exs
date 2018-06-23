defmodule SimpleSoap.Wsdl.Schema.SimpleTypeTest do
  use ExUnit.Case

  import WsdlTestHelper
  alias SimpleSoap.Error.NotImplemented
  alias SimpleSoap.Wsdl.Schema.SimpleType

  test "restriction resolves to the base type" do
    wsdl =
      build_wsdl("""
      <wsdl:types>
        <xsd:schema targetNamespace="http://example.com" xmlns:xsd="http://www.w3.org/1999/XMLSchema">
          <xsd:simpleType name="Foo">
            <xsd:restriction base="xsd:string">
              <xsd:enumeration value="foo"/>
              <xsd:enumeration value="bar"/>
            </xsd:restriction>
          </xsd:simpleType>
        </xsd:schema>
      </wsdl:types>
      """)

    node = SimpleType.nodes(wsdl) |> List.first()
    type_def = SimpleType.type_def(wsdl, node)
    assert {:"http://www.w3.org/1999/XMLSchema", :string} == type_def
  end

  test "list is not implemented" do
    wsdl =
      build_wsdl("""
      <wsdl:types>
        <xsd:schema targetNamespace="http://example.com" xmlns:xsd="http://www.w3.org/1999/XMLSchema">
          <xsd:simpleType name="Foo">
            <xsd:list itemType="xsd:integer" />
          </xsd:simpleType>
        </xsd:schema>
      </wsdl:types>
      """)

    node = SimpleType.nodes(wsdl) |> List.first()
    assert_raise NotImplemented, fn -> SimpleType.type_def(wsdl, node) end
  end

  test "union is not implemented" do
    wsdl =
      build_wsdl("""
      <wsdl:types>
        <xsd:schema targetNamespace="http://example.com" xmlns:xsd="http://www.w3.org/1999/XMLSchema">
          <xsd:simpleType name="Foo">
            <xsd:union memberTypes="sizebyno sizebystring" />
          </xsd:simpleType>
        </xsd:schema>
      </wsdl:types>
      """)

    node = SimpleType.nodes(wsdl) |> List.first()
    assert_raise NotImplemented, fn -> SimpleType.type_def(wsdl, node) end
  end
end
