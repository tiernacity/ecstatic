defmodule Ecstatic.Types.Handler do
  @derive Jason.Encoder
  use Domo, skip_defaults: true

  use TypedStruct

  @type handler :: list()
  typedstruct do
    field :mfa, handler, enforce: true
  end

  # TODO: workaround dialyzer warning from domo __precond__ generator
  precond(t: fn _ -> :ok end)

  def empty() do
    __MODULE__.new!(%{mfa: [__MODULE__, :dummy, []]})
  end

  def dummy(_) do
    {:ok, []}
  end
end
