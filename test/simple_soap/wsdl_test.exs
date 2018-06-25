defmodule SimpleSoap.WsdlTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl
  import WsdlTestHelper

  test "saves the target namespace" do
    assert %Wsdl{target_namespace: target_namespace} = create_wsdl("multiple_bindings.wsdl")
    assert target_namespace == :"http://example.com/methods"
  end

  test "contains a list of all bindings" do
    assert %Wsdl{bindings: bindings} = create_wsdl("multiple_bindings.wsdl")
    assert Enum.count(bindings) == 2
    assert %Wsdl.Binding{} = List.first(bindings)
  end
end
