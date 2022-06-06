defmodule Ecstatic.ConfigureApplication.SystemTest do
  use Ecstatic.DataCase

  alias Ecstatic.Commands
  alias Ecstatic.Events

  test "Can add systems idempotently" do
    systems = %{
      a: %Commands.ConfigureApplication.System{},
      b: %Commands.ConfigureApplication.System{}
    }
    assert :ok = Ecstatic.Commanded.dispatch(%Commands.ConfigureApplication{id: 4, systems: systems}) 

    assert_receive_event(
      Ecstatic.Commanded,
      Events.SystemConfigured,
      fn event ->
        event.name == "a"
      end,
      fn event ->
        assert event.application_id == 4
      end
    )

    assert_receive_event(
      Ecstatic.Commanded,
      Events.SystemConfigured,
      fn event ->
        event.name == "b"
      end,
      fn event ->
        assert event.application_id == 4
      end
    )

    refute_receive_event(
      Ecstatic.Commanded,
      Events.SystemConfigured,
      fn -> Ecstatic.Commanded.dispatch(%Commands.ConfigureApplication{id: 4, systems: systems}) end
    )
  end

  test "Can remove systems" do
    systems_a = %{
      a: %Commands.ConfigureApplication.System{},
      b: %Commands.ConfigureApplication.System{}
    }
    systems_b = %{
      a: %Commands.ConfigureApplication.System{},
    }
    assert :ok = Ecstatic.Commanded.dispatch(%Commands.ConfigureApplication{id: 4, systems: systems_a}) 
    assert :ok = Ecstatic.Commanded.dispatch(%Commands.ConfigureApplication{id: 4, systems: systems_b}) 

    assert_receive_event(
      Ecstatic.Commanded,
      Events.SystemRemoved,
      fn event ->
        assert event.name == "b"
        assert event.application_id == 4
      end
    )
  end

  test "Can remove an application" do
    systems = %{
      a: %Commands.ConfigureApplication.System{}
    }
    assert :ok = Ecstatic.Commanded.dispatch(%Commands.ConfigureApplication{id: 4, systems: systems}) 
    assert :ok = Ecstatic.Commanded.dispatch(%Commands.RemoveApplication{id: 4}) 

    assert_receive_event(
      Ecstatic.Commanded,
      Events.SystemRemoved,
      fn event ->
        assert event.name == "a"
        assert event.application_id == 4
      end
    )
  end
end