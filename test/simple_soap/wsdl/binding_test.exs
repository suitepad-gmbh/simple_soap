defmodule SimpleSoap.Wsdl.BindingTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl.Binding
  alias SimpleSoap.Wsdl
  import WsdlTestHelper
  import SweetXml

  setup do
    %Wsdl{doc: doc} =
      wsdl = load_wsdl("multiple_bindings.wsdl", target_namespace: :"http://example.com/methods")

    node =
      xpath(
        doc,
        ~x"/wsdl:definitions/wsdl:binding"e
        |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      )

    binding = Binding.new(node, wsdl)

    {:ok, %{binding: binding, node: node, wsdl: wsdl}}
  end

  describe "#new" do
    test "returns a binding struct", %{binding: binding} do
      assert %Binding{name: name, type: type} = binding
      assert name == :FooBinding
      assert type == {:"http://example.com/methods", :FooPortType}
    end

    test "contains the binding operations", %{binding: binding} do
      assert %Binding{operations: operations} = binding

      assert {:"http://example.com/actions/AAction", {:"http://example.com/methods", :AAction}} ==
               List.keyfind(operations, :"http://example.com/actions/AAction", 0)
    end
  end
end
