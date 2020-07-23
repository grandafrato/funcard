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
  @player1 Player.new("Player 1")
  @player2 Player.new("Player 2")
  @game_state GameState.new(@deck, [@player1])

  describe "apply_event/1" do
    test "will rasie if there is no associated function for the event" do
      assert_raise UndefinedFunctionError, fn ->
        GameState.apply_event(@game_state, Event.new(:foo, []))
      end
    end

    test "will apply event if associated function exists" do
      assert GameState.apply_event(@game_state, Event.add_player(@player1)) ==
               GameState.add_player(@game_state, @player1)
    end
  end

  test "add_player/2 adds a player to the GameState" do
    assert GameState.add_player(@game_state, @player1) ==
             GameState.new(@deck, [@player1, @player1])
  end

  test "start_game/1 starts a game by giving each player 5 new cards and setting the round to 1" do
    game_state = @game_state |> GameState.add_player(@player2) |> GameState.start_game()

    deck =
      Map.put(@deck, :player_cards, Enum.take(@deck.player_cards, -2))
      |> Map.put(:table_cards, List.delete_at(@deck.table_cards, 0))

    updated_player_cards = Enum.drop_every(Enum.take(@deck.player_cards, 10), 2)
    updated_player2_cards = Enum.take_every(Enum.take(@deck.player_cards, 10), 2)

    updated_player = Map.put(@player1, :hand, updated_player_cards)
    updated_player2 = Map.put(@player2, :hand, updated_player2_cards)

    assert game_state == %GameState{
             card_in_play: hd(@deck.table_cards),
             deck: deck,
             players: [updated_player2, updated_player],
             round: 1,
             turn: @player1.id
           }
  end

  test "play_card/3 plays the given player's card selected by index" do
    game_state = GameState.start_game(@game_state)

    {card, player} = game_state.players |> List.last() |> Player.play_card(1)

    assert GameState.play_card(game_state, @player1.id, 1) == %GameState{
             card_in_play: hd(@deck.table_cards),
             deck: game_state.deck,
             players: [player],
             played_cards: [{@player1.id, card}],
             round: 1,
             turn: @player1.id
           }
  end

  describe "end_round/2" do
    test "gives each player the amount of cards they need" do
      game_state =
        @game_state
        |> GameState.add_player(@player2)
        |> GameState.start_game()
        |> GameState.play_card(@player2.id, 1)
        |> GameState.end_round(0)

      assert game_state.players |> Enum.map(&Enum.count(&1.hand)) |> Enum.dedup() == [5]
    end

    test "ups the round number" do
      game_state =
        @game_state
        |> GameState.add_player(@player2)
        |> GameState.start_game()
        |> GameState.play_card(@player2.id, 1)
        |> GameState.end_round(0)

      assert game_state.round == 2
    end

    test "gives the player the card won" do
      game_state =
        @game_state
        |> GameState.add_player(@player2)
        |> GameState.start_game()
        |> GameState.play_card(@player2.id, 1)

      assert game_state
             |> GameState.end_round(0)
             |> Map.fetch!(:players)
             |> List.first()
             |> Map.fetch!(:cards_won) == [game_state.card_in_play]
    end

    test "makes it the next player's turn" do
      game_state =
        @game_state
        |> GameState.add_player(@player2)
        |> GameState.start_game()
        |> GameState.play_card(@player2.id, 1)
        |> GameState.end_round(0)

      assert game_state.turn == @player2.id
    end

    test "draws the next table card" do
      game_state =
        @game_state
        |> GameState.add_player(@player2)
        |> GameState.start_game()
        |> GameState.play_card(@player2.id, 1)
        |> GameState.end_round(0)

      assert game_state.card_in_play == %Card{data: "two {||}"}
    end
  end
end
