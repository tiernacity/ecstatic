defmodule Ecstatic.Types.EntityComponentId do
  use Domo, skip_defaults: true
  use TypedStruct

  typedstruct do
    field :application_id, Ecstatic.Types.ApplicationId.t(), enforce: true
    field :component_name, Ecstatic.Types.Names.Component.t(), enforce: true
    field :entity_id, String.t(), enforce: true
  end

  # TODO: workaround dialyzer warning from domo __precond__ generator
  precond(t: fn _ -> :ok end)
end

defimpl String.Chars, for: Ecstatic.Types.Names.EntityComponentId do
  # TODO: Do better here
  def to_string(value), do: "#{value.application_id}.#{value.component_name}.#{value.entity_id}"
end