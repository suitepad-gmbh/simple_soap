defmodule SimpleSoap.Wsdl.Schema.Type.All do
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema.Type.All

  require Logger

  defstruct elements: []

  def parse_value(_node, %All{}, %Wsdl{}) do
    Logger.error("Complex type 'all' not yet implemented")
    nil
  end
end
