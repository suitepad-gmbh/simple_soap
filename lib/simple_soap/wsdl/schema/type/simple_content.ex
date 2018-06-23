defmodule SimpleSoap.Wsdl.Schema.Type.SimpleContent do
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema.Type.SimpleContent

  require Logger

  defstruct elements: []

  def parse_value(_node, %SimpleContent{}, %Wsdl{}) do
    Logger.error("Complex type 'simpleContent' not yet implemented")
    nil
  end
end
