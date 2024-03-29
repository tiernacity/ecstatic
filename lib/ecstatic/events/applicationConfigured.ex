defmodule Ecstatic.Events.ApplicationConfigured do
  use Domo, skip_defaults: true
  @derive Jason.Encoder
  alias Ecstatic.Types

  use TypedStruct

  typedstruct do
    field :id, Types.ApplicationId.t(), enforce: true
  end

  # TODO: workaround dialyzer warning from domo __precond__ generator
  precond(t: fn _ -> :ok end)
end
