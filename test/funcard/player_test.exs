defmodule Funcard.PlayerTest do
  use ExUnit.Case, async: true

  alias Funcard.Deck.Card
  alias Funcard.Player

  doctest Player

  @hand [%Card{data: "foo"}, %Card{data: "bar"}, %Card{data: "baz"}]
  @cards_won [
    %Card{data: "I only eat grass with {||}."},
    %Card{data: "Sometimes, I eat with my {|1|} and my {|2|}!"}
  ]
  @player %Player{
    name: "Johnny",
    hand: @hand,
    cards_won: @cards_won
  }

  describe "play_card/2" do
    test "it returns the card played" do
      {card, _} = Player.play_card(@player, 1)

      assert card == List.first(@hand)
    end

    test "it returns the player struct without the played card in the hand" do
      {_, player} = Player.play_card(@player, 1)

      assert player == Map.put(@player, :hand, List.delete_at(@hand, 0))
    end
  end

  describe "win_card/2" do
    test "it adds a card to the cards_won list" do
      card = %Card{data: "{||} is awesome!"}
      player = Player.win_card(@player, card)

      assert player == Map.put(@player, :cards_won, [card | @cards_won])
    end
  end
end
