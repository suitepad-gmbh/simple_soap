defmodule SimpleSoap.Wsdl.SchemaTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema
  import SweetXml
  import WsdlTestHelper

  describe "#new" do
    setup do
      %Wsdl{doc: doc} = wsdl = load_wsdl("types.wsdl")

      parent =
        xpath(
          doc,
          ~x"/wsdl:definitions/wsdl:types"e
          |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
        )

      {:ok, %{wsdl: wsdl, parent: parent}}
    end

    test "creates a list of schemas", %{wsdl: wsdl, parent: parent} do
      schemas = Schema.new(parent, wsdl)

      assert Enum.count(schemas) == 2
      assert {:"http://example.com/schemas/methods", %Schema{}} = List.first(schemas)
      assert {:"http://example.com/schemas/objects", %Schema{}} = List.last(schemas)
    end

    test "the methods schema contains the method types", %{wsdl: wsdl, parent: parent} do
      {_, schema} =
        Schema.new(parent, wsdl)
        |> List.keyfind(:"http://example.com/schemas/methods", 0)

      assert %Schema{items: items} = schema
      assert [GetContactsResponse: %Schema.Type.Sequence{}] = items
    end

    test "the objects schema contains the object types", %{wsdl: wsdl, parent: parent} do
      {_, schema} =
        Schema.new(parent, wsdl)
        |> List.keyfind(:"http://example.com/schemas/objects", 0)

      assert %Schema{items: items} = schema
      assert {:Phone, %Schema.Type.Sequence{}} = List.keyfind(items, :Phone, 0)
      assert {:Telephone, %Schema.Type.Reference{}} = List.keyfind(items, :Telephone, 0)
      assert {:Contact, %Schema.Type.Sequence{}} = List.keyfind(items, :Contact, 0)
      assert {:Person, %Schema.Type.All{}} = List.keyfind(items, :Person, 0)

      assert {:PhoneType, {:"http://www.w3.org/1999/XMLSchema", :string}} =
               List.keyfind(items, :PhoneType, 0)
    end
  end
end
