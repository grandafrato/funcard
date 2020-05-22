defmodule Funcard.DeckTest do
  use ExUnit.Case, async: true
  alias Funcard.Deck
  alias Funcard.Deck.Card

  doctest Deck, except: [{:shuffle, 1}]

  @player_cards [
    %Card{data: "card 1"},
    %Card{data: "card 2"},
    %Card{data: "card 3"},
    %Card{data: "card 4"}
  ]
  @table_cards [
    %Card{data: "{||} 1"},
    %Card{data: "{||} 2"},
    %Card{data: "{||} 3"},
    %Card{data: "{||} 4"}
  ]

  @deck1 %Deck{name: "Deck1", player_cards: @player_cards, table_cards: @table_cards}
  @deck2 %Deck{
    name: "Deck2",
    player_cards: [%Card{data: "not good card"}],
    table_cards: [%Card{data: "{||} oof"}]
  }

  describe "shuffle/1" do
    test "shuffled player cards contain the same cards" do
      %{player_cards: shuffled_player_cards} = Deck.shuffle(@deck1)

      assert Enum.all?(shuffled_player_cards, &Enum.member?(@player_cards, &1))
    end

    test "shuffled table cards are shuffled contain the same cards" do
      %{table_cards: shuffled_table_cards} = Deck.shuffle(@deck1)
      assert Enum.all?(shuffled_table_cards, &Enum.member?(@table_cards, &1))
    end

    test "the shuffled and not shuffled decks are not equal" do
      assert Deck.shuffle(@deck1) != @deck1
    end
  end

  describe "merge/2" do
    test "merges the names of the decks" do
      merged_deck = Deck.merge(@deck1, @deck2)

      assert merged_deck.name == "#{@deck1.name} + #{@deck2.name}"
    end

    test "merges the player cards" do
      merged_deck = Deck.merge(@deck1, @deck2)

      assert merged_deck.player_cards == [%Card{data: "not good card"} | @player_cards]
    end

    test "merges the table cards" do
      merged_deck = Deck.merge(@deck1, @deck2)

      assert merged_deck.table_cards == [%Card{data: "{||} oof"} | @table_cards]
    end

    test "returns the second argument when the first is nil" do
      merged_deck = Deck.merge(nil, @deck2)

      assert merged_deck == @deck2
    end
  end
end
