defmodule Funcard.PlayerTest do
  use ExUnit.Case, async: true

  alias Funcard.Deck
  alias Funcard.Deck.Card
  alias Funcard.Player

  doctest Player

  @hand [%Card{data: "foo"}, %Card{data: "bar"}, %Card{data: "baz"}]
  @deck %Deck{
    name: "Bar Deck",
    player_cards: [
      %Card{data: "slom"},
      %Card{data: "*cries*"},
      %Card{data: "toes"},
      %Card{data: "bananana"},
      %Card{data: "Craig"},
      %Card{data: "pizza"},
      %Card{data: "lizard"}
    ],
    table_cards: [%Card{data: "one {||}"}, %Card{data: "two {||}"}, %Card{data: "three {||}"}]
  }
  @cards_won [Enum.fetch!(@deck.table_cards, 0), Enum.fetch!(@deck.table_cards, 1)]
  @player Player.new("Johnny")

  describe "draw_card/2" do
    test "adds the first available card to the hand" do
      [card | leftover_cards] = @deck.player_cards
      player = List.foldr(@hand, @player, &Map.put(&2, :hand, [&1 | &2.hand]))

      assert Player.draw_card(player, @deck.player_cards) ==
               {Map.put(@player, :hand, [card | @hand]), leftover_cards}
    end

    test "it's also pipeable" do
      [card1, card2 | leftover_cards] = @deck.player_cards
      player = List.foldr(@hand, @player, &Map.put(&2, :hand, [&1 | &2.hand]))

      assert Player.draw_card(player, @deck.player_cards) |> Player.draw_card() ==
               {Map.put(@player, :hand, [card2, card1 | @hand]), leftover_cards}
    end
  end

  describe "play_card/2" do
    test "it returns the card played" do
      {card, _} =
        List.foldr(@hand, @player, &Map.put(&2, :hand, [&1 | &2.hand]))
        |> Player.play_card(1)

      assert card == List.first(@hand)
    end

    test "it returns the player struct without the played card in the hand" do
      {_, player} =
        List.foldr(@hand, @player, &Map.put(&2, :hand, [&1 | &2.hand]))
        |> Player.play_card(1)

      assert player == Map.put(@player, :hand, List.delete_at(@hand, 0))
    end
  end

  test "win_card/1 adds a card to the cards_won list" do
    card = %Card{data: "{||} is awesome!"}

    player =
      List.foldr(@cards_won, @player, &Player.win_card(&2, &1))
      |> Player.win_card(card)

    assert player == Map.put(@player, :cards_won, [card | @cards_won])
  end
end
