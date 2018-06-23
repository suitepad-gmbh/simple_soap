defmodule SimpleSoap.Wsdl.TypesTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl.Schema
  alias SimpleSoap.Wsdl.Types
  import WsdlTestHelper

  describe "#new" do
    test "returns a types struct with schemas" do
      assert %Types{schemas: schemas} =
               load_wsdl("types.wsdl")
               |> Types.new()

      assert Enum.count(schemas) == 2
      assert {:"http://example.com/schemas/methods", %Schema{}} = List.first(schemas)
    end
  end
end
