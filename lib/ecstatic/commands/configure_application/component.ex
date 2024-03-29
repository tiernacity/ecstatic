defmodule Ecstatic.Commands.ConfigureApplication.Component do
  alias Ecstatic.Types

  use TypedStruct

  typedstruct do
    field :schema, Types.Schema.t(), enforce: true
    field :commands, map(), default: %{}
    field :events, map(), default: %{}
    field :subscribers, map(), default: %{}
  end

  def empty() do
    %__MODULE__{
      schema: Types.Schema.empty()
    }
  end
end
