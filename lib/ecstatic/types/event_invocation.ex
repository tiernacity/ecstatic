defmodule Ecstatic.Types.EventInvocation do
  use TypedStruct
  @derive Jason.Encoder
  alias Ecstatic.Types

  typedstruct do
    field :application, String.t(), enforce: true
    field :event, String.t(), enforce: true
    field :entity_component, String.t(), enforce: true
    field :payload, Types.Payload.t(), enforce: true
  end
end
