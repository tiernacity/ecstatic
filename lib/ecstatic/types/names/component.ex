defmodule Ecstatic.Types.Names.Component do
  use Domo, skip_defaults: true
  alias Ecstatic.Types.Names

  defstruct [
    :system,
    :component
  ]

  @type t() :: %__MODULE__{
          system: Names.t(),
          component: Names.t()
        }
  # TODO: workaround dialyzer warning from domo __precond__ generator
  precond(t: fn _ -> :ok end)
end

defimpl String.Chars, for: Ecstatic.Types.Names.Component do
  def to_string(value), do: "#{value.system}.component.#{value.component}"
end
