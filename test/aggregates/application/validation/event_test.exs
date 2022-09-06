defmodule Ecstatic.Test.Aggregates.Application.Validation.Event do
  use Ecstatic.DataCase

  alias Ecstatic.Commanded.Commands
  alias Ecstatic.Commanded.Events
  alias Ecstatic.Commanded.Types

  test "Rejects periods in names" do
    good_name = "a-name_with(different*characters&and1numbers,"
    bad_name = "a-name-a.period"

    systems_good = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            events: %{
              good_name => Commands.ConfigureApplication.Event.empty()
            }
          }
        }
      }
    }

    systems_bad = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            events: %{
              bad_name => Commands.ConfigureApplication.Event.empty()
            }
          }
        }
      }
    }

    assert :ok =
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_good
             })

    refute match?(
             :ok,
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_bad
             })
           )

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.EventConfigured,
      fn event ->
        event.name == "a.event.#{good_name}"
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )
  end

  test "Rejects duplicate names" do
    systems_good = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            events: %{
              "d" => Commands.ConfigureApplication.Event.empty()
            }
          },
          "c" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            events: %{
              "e" => Commands.ConfigureApplication.Event.empty()
            }
          }
        }
      }
    }

    systems_bad = %{
      "a" => %Commands.ConfigureApplication.System{
        components: %{
          "b" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            events: %{
              "d" => Commands.ConfigureApplication.Event.empty()
            }
          },
          "c" => %Commands.ConfigureApplication.Component{
            schema: Types.Schema.empty(),
            events: %{
              "d" => Commands.ConfigureApplication.Event.empty()
            }
          }
        }
      }
    }

    assert :ok =
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_good
             })

    refute match?(
             :ok,
             Ecstatic.configure_application(%Commands.ConfigureApplication{
               name: "4",
               systems: systems_bad
             })
           )

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.EventConfigured,
      fn event ->
        event.name == "a.event.d"
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.b"
      end
    )

    assert_receive_event(
      Ecstatic.Commanded.Application,
      Events.EventConfigured,
      fn event ->
        event.name == "a.event.e"
      end,
      fn event ->
        assert event.application == "4"
        assert event.component == "a.component.c"
      end
    )
  end
end
