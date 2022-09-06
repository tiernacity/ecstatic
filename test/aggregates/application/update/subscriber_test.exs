defmodule Ecstatic.Test.Aggregates.Application.Update.Subscriber do
  use Ecstatic.DataCase

  alias Ecstatic.Commanded.Commands
  alias Ecstatic.Commanded.Events
  alias Ecstatic.Commanded.Types

  test "Allows a change of handler" do
    mfa_a = [__MODULE__, :handler_a, 1]
    mfa_b = [__MODULE__, :handler_b, 1]

    systems_a = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            subscribers: %{
              "c" => %Commands.ConfigureApplication.Subscriber{
                trigger: Types.Trigger.empty(),
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
            subscribers: %{
              "c" => %Commands.ConfigureApplication.Subscriber{
                trigger: Types.Trigger.empty(),
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
      Events.SubscriberConfigured,
      fn event ->
        event.name == "a.subscriber.c" &&
          event.handler.mfa == mfa_a
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.SubscriberConfigured,
      fn event ->
        event.name == "a.subscriber.c" &&
          event.handler.mfa == mfa_b
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )
  end

  test "Allows a change of trigger" do
    component_a = "a.component.a"
    component_b = "a.component.b"

    systems_a = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            subscribers: %{
              "c" => %Commands.ConfigureApplication.Subscriber{
                handler: Types.Handler.empty(),
                trigger:
                  Types.Trigger.new!(%{
                    component: component_a
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
            subscribers: %{
              "c" => %Commands.ConfigureApplication.Subscriber{
                handler: Types.Handler.empty(),
                trigger:
                  Types.Trigger.new!(%{
                    component: component_b
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
      Events.SubscriberConfigured,
      fn event ->
        event.name == "a.subscriber.c" &&
          event.trigger.component == component_a
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.SubscriberConfigured,
      fn event ->
        event.name == "a.subscriber.c" &&
          event.trigger.component == component_b
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )
  end
end
