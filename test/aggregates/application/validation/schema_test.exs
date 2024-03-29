defmodule Ecstatic.Test.Aggregates.Application.Validation.Schema do
  use Ecstatic.DataCase

  alias Ecstatic.Commands
  alias Ecstatic.Events
  alias Ecstatic.Types

  test "Rejects invalid schema" do
    good_schema = Jason.encode!(%{"type" => "null"})
    bad_schema = ["foo", String.slice(good_schema, 0..-2)]

    systems_good = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            events: %{
              "c" => %Commands.ConfigureApplication.Event{
                schema: %Types.Schema{json_schema: good_schema},
                handler: Types.Handler.empty()
              }
            }
          }
        }
      }
    }

    assert :ok =
             Ecstatic.Commanded.dispatch(%Commands.ConfigureApplication{
               id: 4,
               systems: systems_good
             })

    assert_receive_event(
      Ecstatic.Commanded,
      Events.EventConfigured,
      fn event ->
        event.name == "a.event.c" &&
          event.schema.json_schema == good_schema
      end,
      fn event ->
        assert event.application_id == 4
      end
    )

    Enum.each(bad_schema, fn s ->
      systems_bad = %{
        "a" => %Commands.ConfigureApplication.System{
          components: %{
            "b" => %Commands.ConfigureApplication.Component{
              schema: Types.Schema.empty(),
              events: %{
                "c" => %Commands.ConfigureApplication.Event{
                  schema: %Types.Schema{json_schema: s},
                  handler: Types.Handler.empty()
                }
              }
            }
          }
        }
      }

      refute match?(
               :ok,
               Ecstatic.Commanded.dispatch(%Commands.ConfigureApplication{
                 id: 4,
                 systems: systems_bad
               })
             )
    end)
  end
end
