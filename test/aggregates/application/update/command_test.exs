defmodule Ecstatic.Test.Aggregates.Application.Update.Command do
  use Ecstatic.DataCase

  alias Ecstatic.Commanded.Commands
  alias Ecstatic.Commanded.Events
  alias Ecstatic.Commanded.Types

  test "Rejects a change of schema" do
    schema_a = Jason.encode!(%{"type" => "null"})
    schema_b = Jason.encode!(%{"type" => "boolean"})

    systems_a = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            commands: %{
              "c" => %Commands.ConfigureApplication.Command{
                schema:
                  Types.Schema.new!(%{
                    json_schema: schema_a
                  }),
                handler: Types.Handler.empty()
              }
            }
          }
        }
      }
    }

    systems_b = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            commands: %{
              "c" => %Commands.ConfigureApplication.Command{
                schema:
                  Types.Schema.new!(%{
                    json_schema: schema_b
                  }),
                handler: Types.Handler.empty()
              }
            }
          }
        }
      }
    }

    assert :ok =
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_a
             })

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.CommandConfigured,
      fn event ->
        event.name == "a.command.c" &&
          event.schema.json_schema == schema_a
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )

    refute match?(
             :ok,
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_b
             })
           )
  end

  test "Allows a change of handler" do
    mfa_a = [__MODULE__, :handler_a, 1]
    mfa_b = [__MODULE__, :handler_b, 1]

    systems_a = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            commands: %{
              "c" => %Commands.ConfigureApplication.Command{
                schema: Types.Schema.empty(),
                handler:
                  Types.Handler.new!(%{
                    mfa: mfa_a
                  })
              }
            }
          }
        }
      }
    }

    systems_b = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            commands: %{
              "c" => %Commands.ConfigureApplication.Command{
                schema: Types.Schema.empty(),
                handler:
                  Types.Handler.new!(%{
                    mfa: mfa_b
                  })
              }
            }
          }
        }
      }
    }

    assert :ok =
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_a
             })

    assert :ok =
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_b
             })

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.CommandConfigured,
      fn event ->
        event.name == "a.command.c" &&
          event.handler.mfa == mfa_a
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.CommandConfigured,
      fn event ->
        event.name == "a.command.c" &&
          event.handler.mfa == mfa_b
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )
  end
end
