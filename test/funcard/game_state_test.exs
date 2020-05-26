defmodule Funcard.GameStateTest do
  use ExUnit.Case, async: true

  alias Funcard.{Deck, Deck.Card, Event, GameState, Player}

  @deck %Deck{
    name: "Bar Deck",
    player_cards: [
      %Card{data: "slow"},
      %Card{data: "*cries*"},
      %Card{data: "toes"},
      %Card{data: "bananana"},
      %Card{data: "Craig"},
      %Card{data: "pizza"},
      %Card{data: "lizard"},
      %Card{data: "fasd"},
      %Card{data: "lololololo"},
      %Card{data: "feet"},
      %Card{data: "bar"},
      %Card{data: "baz"}
    ],
    table_cards: [%Card{data: "one {||}"}, %Card{data: "two {||}"}, %Card{data: "three {||}"}]
  }
  @player Player.new("Foo")
  @game_state GameState.new(@deck, [@player])

  describe "apply_event/1" do
    test "will rasie if there is no associated function for the event" do
      assert_raise UndefinedFunctionError, fn ->
        GameState.apply_event(@game_state, Event.new(:foo, []))
      end
    end

    test "will apply event if associated function exists" do
      assert GameState.apply_event(@game_state, Event.add_player(@player)) ==
               GameState.add_player(@game_state, @player)
    end
  end

  test "add_player/2 adds a player to the GameState" do
    assert GameState.add_player(@game_state, @player) == GameState.new(@deck, [@player, @player])
  end

  test "start_game/1 starts a game by giving each player 5 new cards and setting the round to 1" do
    player2 = Player.new("Player 2")
    game_state = @game_state |> GameState.add_player(player2) |> GameState.start_game()

    deck =
      Map.put(@deck, :player_cards, Enum.take(@deck.player_cards, -2))
      |> Map.put(:table_cards, List.delete_at(@deck.table_cards, 0))

    updated_player_cards = Enum.drop_every(Enum.take(@deck.player_cards, 10), 2)
    updated_player2_cards = Enum.take_every(Enum.take(@deck.player_cards, 10), 2)

    updated_player = Map.put(@player, :hand, updated_player_cards)
    updated_player2 = Map.put(player2, :hand, updated_player2_cards)

    assert game_state == %GameState{
             deck: deck,
             players: [updated_player2, updated_player],
             round: 1,
             turn: @player.id
           }
  end
end
