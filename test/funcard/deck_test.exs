defmodule Funcard.DeckTest do
  use ExUnit.Case, async: true
  alias Funcard.Deck
  alias Funcard.Deck.Card

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

  @deck %Deck{name: "Deck", player_cards: @player_cards, table_cards: @table_cards}

  describe "shuffle/1" do
    test "shuffled player cards contain the same cards" do
      %{player_cards: shuffled_player_cards} = Deck.shuffle(@deck)

      assert Enum.all?(shuffled_player_cards, &Enum.member?(@player_cards, &1))
    end

    test "shuffled table cards are shuffled contain the same cards" do
      %{table_cards: shuffled_table_cards} = Deck.shuffle(@deck)
      assert Enum.all?(shuffled_table_cards, &Enum.member?(@table_cards, &1))
    end

    test "the shuffled and not shuffled decks are not equal" do
      assert Deck.shuffle(@deck) != @deck
    end
  end
end
