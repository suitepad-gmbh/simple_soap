defmodule SimpleSoap.Wsdl.Schema.Type.Reference do
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema.Type.Reference

  require Logger

  defstruct type: nil

  def parse_value(_node, %Reference{}, %Wsdl{}) do
    Logger.error("Type reference is not supported yet")
    nil
  end
end
