defmodule Funcard.GameSessionTest do
  use Funcard.GameCase, async: true

  alias Funcard.{Deck, Event, GameSession, GameState, Player}

  doctest GameSession

  describe "new/2" do
    test "it makes a new game, with the passed in player as admin" do
      game = GameSession.new([@deck1, @deck2], @player, shuffle?: false)

      assert game == %GameSession{
               admin: @player.id,
               events: [],
               initial_state: %GameState{
                 deck: Deck.merge(@deck2, @deck1),
                 players: [@player],
                 round: 0,
                 turn: :nobody
               }
             }
    end

    test "the deck is shuffled by default when creating a new GameSession" do
      %{initial_state: %{deck: deck}} =
        GameSession.new([@deck1, @deck2], @player, shuffle?: false)

      %{initial_state: %{deck: shuffled_deck}} = GameSession.new([@deck1, @deck2], @player)

      assert deck != shuffled_deck

      assert Enum.all?(shuffled_deck.player_cards, &Enum.member?(deck.player_cards, &1))
      assert Enum.all?(shuffled_deck.player_cards, &Enum.member?(deck.player_cards, &1))
    end
  end

  describe "events" do
    test "add_event/2 appends an event to the list of events" do
      event = Event.new(:foo, ["bar", "baz"])

      game =
        GameSession.new([@deck1, @deck2], @player, shuffle?: false)
        |> GameSession.add_event(event)

      assert game == %GameSession{
               admin: @player.id,
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
      event3 = Event.new(:sing, ["a song", "with ears"])
      event4 = Event.new(:really, ["it's true", "I promise"])

      game =
        GameSession.new([@deck1, @deck2], @player, shuffle?: false)
        |> GameSession.add_event(event4)
        |> GameSession.add_event(event2)
        |> GameSession.add_event(event1)
        |> GameSession.add_event(event3)

      assert game == %GameSession{
               admin: @player.id,
               events: [event1, event2, event3, event4],
               initial_state: %GameState{
                 deck: Deck.merge(@deck2, @deck1),
                 players: [@player],
                 round: 0,
                 turn: :nobody
               }
             }
    end

    test "apply_events/1" do
      baz = Player.new("Baz")

      game =
        GameSession.new([@deck1, @deck2], @player, shuffle?: false)
        |> GameSession.add_event(Event.add_player(baz))
        |> GameSession.add_event(Event.start_game())
        |> GameSession.add_event(Event.play_card(baz.id, 1))
        |> GameSession.add_event(Event.end_round(0))

      deck = Deck.merge(@deck2, @deck1)

      [
        _card1
        | [
            card2
            | [
                card3
                | [
                    card4
                    | [
                        card5
                        | [
                            card6
                            | [card7 | [card8 | [card9 | [card10 | [card11 | cards]]]]]
                          ]
                      ]
                  ]
              ]
          ]
      ] = deck.player_cards

      [card_won | [card_in_play | table_cards]] = deck.table_cards

      assert GameSession.apply_events(game) ==
               Map.put(game, :current_state, %GameState{
                 deck: Map.put(deck, :player_cards, cards) |> Map.put(:table_cards, table_cards),
                 card_in_play: card_in_play,
                 players: [
                   Map.put(baz, :cards_won, [card_won])
                   |> Map.put(:hand, [card11, card3, card5, card7, card9]),
                   Map.put(@player, :hand, [card2, card4, card6, card8, card10])
                 ],
                 round: 2,
                 turn: baz.id
               })
    end
  end
end
