defmodule Ecstatic.Applications.Events.EventRemoved do
  @derive Jason.Encoder
  defstruct [:application_id, :name]
end
