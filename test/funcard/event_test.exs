defmodule Funcard.EventTest do
  use ExUnit.Case, async: true

  alias Funcard.Deck.Card
  alias Funcard.Event
  alias Funcard.Player

  test "add_player/1" do
    assert event_to_timeless_map(Event.add_player(%Player{name: "Foo"})) == %{
             args: [%Player{name: "Foo"}],
             event: :add_player
           }
  end

  test "end_game/1" do
    assert event_to_timeless_map(Event.end_game(%Player{name: "Foo"})) == %{
             args: [%Player{name: "Foo"}],
             event: :end_game
           }
  end

  test "end_round/2" do
    assert event_to_timeless_map(Event.end_round(%Player{name: "Foo"}, %Player{name: "Winner"})) ==
             %{
               args: [%Player{name: "Foo"}, %Player{name: "Winner"}],
               event: :end_round
             }
  end

  test "play_card/2" do
    assert event_to_timeless_map(Event.play_card(%Player{name: "Foo"}, %Card{data: "boo"})) == %{
             args: [%Player{name: "Foo"}, %Card{data: "boo"}],
             event: :play_card
           }
  end

  test "quit_player/1" do
    assert event_to_timeless_map(Event.quit_player(%Player{name: "Foo"})) == %{
             args: [%Player{name: "Foo"}],
             event: :quit_player
           }
  end

  test "start_game/1" do
    assert event_to_timeless_map(Event.start_game(%Player{name: "Foo"})) == %{
             args: [%Player{name: "Foo"}],
             event: :start_game
           }
  end

  defp event_to_timeless_map(event) do
    Map.from_struct(event) |> Map.delete(:timestamp)
  end
end
