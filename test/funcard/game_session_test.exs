defmodule Funcard.GameTest do
  use ExUnit.Case

  alias Funcard.Deck
  alias Funcard.Deck.Card
  alias Funcard.Event
  alias Funcard.GameSession
  alias Funcard.GameState
  alias Funcard.Player

  @hand [%Card{data: "bar"}, %Card{data: "baz"}]
  @deck1 %Deck{
    name: "Foo Deck",
    player_cards: [%Card{data: "fasd"}, %Card{data: "lololololo"}, %Card{data: "feet"} | @hand],
    table_cards: [%Card{data: "1 {||}"}, %Card{data: "2 {||}"}, %Card{data: "3 {||}"}]
  }
  @deck2 %Deck{
    name: "Bar Deck",
    player_cards: [%Card{data: "slom"}, %Card{data: "*cries*"}, %Card{data: "toes"} | @hand],
    table_cards: [%Card{data: "one {||}"}, %Card{data: "two {||}"}, %Card{data: "three {||}"}]
  }
  @player %Player{name: "Foo"}

  describe "new/2" do
    test "it makes a new game, with the passed in player as admin" do
      game = GameSession.new([@deck1, @deck2], @player)

      assert game == %GameSession{
               admin: @player,
               events: [],
               initial_state: %GameState{
                 deck: Deck.merge(@deck2, @deck1),
                 players: [@player],
                 round: 0,
                 turn: :nobody
               }
             }
    end
  end

  describe "events" do
    test "add_event/2 appends an event to the list of events" do
      event = Event.new(:foo, ["bar", "baz"])
      game = GameSession.new([@deck1, @deck2], @player) |> GameSession.add_event(event)

      assert game == %GameSession{
               admin: @player,
               events: [event],
               initial_state: %GameState{
                 deck: Deck.merge(@deck2, @deck1),
                 players: [@player],
                 round: 0,
                 turn: :nobody
               }
             }
    end

    test "events are sorted by timestamp, not the order added" do
      event1 = Event.new(:foo, ["bar", "baz"])
      event2 = Event.new(:eat, ["not soap,", "but bars"])

      game =
        GameSession.new([@deck1, @deck2], @player)
        |> GameSession.add_event(event2)
        |> GameSession.add_event(event1)

      assert game == %GameSession{
               admin: @player,
               events: [event2, event1],
               initial_state: %GameState{
                 deck: Deck.merge(@deck2, @deck1),
                 players: [@player],
                 round: 0,
                 turn: :nobody
               }
             }
    end
  end
end