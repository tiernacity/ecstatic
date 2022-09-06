defmodule Ecstatic.Commanded.Events.ComponentConfigured do
  use Domo, skip_defaults: true
  @derive Jason.Encoder
  alias Ecstatic.Commanded.Types

  use TypedStruct

  typedstruct do
    field :application, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :schema, Types.Schema.t(), enforce: true
  end

  # TODO: workaround dialyzer warning from domo __precond__ generator
  precond(t: fn _ -> :ok end)
end

defimpl Commanded.Serialization.JsonDecoder, for: Ecstatic.Commanded.Events.ComponentConfigured do
  def decode(%Ecstatic.Commanded.Events.ComponentConfigured{schema: schema} = event) do
    %Ecstatic.Commanded.Events.ComponentConfigured{event | schema: struct(Ecstatic.Commanded.Types.Schema, schema)}
  end
end