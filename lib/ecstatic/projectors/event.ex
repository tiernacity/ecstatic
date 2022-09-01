defmodule Ecstatic.Projectors.Event do
  use Commanded.Projections.Ecto,
    application: Ecstatic.Commanded,
    repo: Ecstatic.Repo,
    name: "Projectors.Event",
    consistency: :strong

  alias Ecstatic.Events
  alias Ecstatic.Projections.Event

  project(%Events.EventConfigured{} = event, _metadata, fn multi ->
    event = %Event{
      application: event.application,
      component: event.component,
      name: event.name,
      schema: event.schema,
      handler: event.handler
    }

    Ecto.Multi.insert(multi, :event, event,
      on_conflict: [set: [handler: event.handler]],
      conflict_target: [:application, :name]
    )
  end)

  project(%Events.EventRemoved{} = event, _metadata, fn multi ->
    query =
      from(c in Event, where: c.application == ^event.application and c.name == ^event.name)

    Ecto.Multi.delete_all(multi, :event, query)
  end)
end
