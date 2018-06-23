defmodule SimpleSoap.RequestTest do
  use ExUnit.Case

  alias SimpleSoap.Wsdl
  alias SimpleSoap.Request

  setup do
    wsdl =
      File.read!("test/fixtures/snowboard_example/example.wsdl")
      |> Wsdl.new()

    {:ok, %{wsdl: wsdl}}
  end

  test "#read returns a port type map", %{wsdl: wsdl} do
    body = File.read!("test/fixtures/snowboard_example/request.xml")

    assert %Request{operation: operation, params: params} =
             Request.new(wsdl, :GetEndorsingBoarderPortType, body)

    assert operation.name == :GetEndorsingBoarder
    assert Map.has_key?(params, :body)
  end
end
