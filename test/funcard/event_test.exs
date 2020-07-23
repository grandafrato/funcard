defmodule Funcard.EventTest do
  use ExUnit.Case, async: true

  alias Funcard.Event
  alias Funcard.Player

  @player Player.new("Foo")

  test "add_player/1" do
    assert event_to_timeless_map(Event.add_player(@player)) == %{
             args: [@player],
             event: :add_player
           }
  end

  test "end_game/0" do
    assert event_to_timeless_map(Event.end_game()) == %{args: [], event: :end_game}
  end

  test "end_round/1" do
    assert event_to_timeless_map(Event.end_round(0)) == %{
             args: [0],
             event: :end_round
           }
  end

  test "play_card/2" do
    assert event_to_timeless_map(Event.play_card(@player, 1)) == %{
             args: [@player, 1],
             event: :play_card
           }
  end

  test "quit_player/1" do
    assert event_to_timeless_map(Event.quit_player(@player)) == %{
             args: [@player],
             event: :quit_player
           }
  end

  test "start_game/0" do
    assert event_to_timeless_map(Event.start_game()) == %{args: [], event: :start_game}
  end

  defp event_to_timeless_map(event) do
    Map.from_struct(event) |> Map.delete(:timestamp)
  end
end
