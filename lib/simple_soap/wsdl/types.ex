defmodule SimpleSoap.Wsdl.Types do
  import SweetXml
  alias SimpleSoap.Wsdl
  alias SimpleSoap.Wsdl.Schema

  defstruct schemas: []

  def new(%Wsdl{doc: doc} = wsdl) do
    schemas =
      xpath(
        doc,
        ~x"/wsdl:definitions/wsdl:types"e
        |> add_namespace("wsdl", "http://schemas.xmlsoap.org/wsdl/")
      )
      |> Schema.new(wsdl)

    %__MODULE__{schemas: schemas}
  end
end
