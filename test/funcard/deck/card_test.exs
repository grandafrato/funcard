defmodule Funcard.Deck.CardTest do
  use ExUnit.Case, async: true
  alias Funcard.Deck.Card

  @basic_card %Card{data: "I am addicted to eating {||}."}
  @multi_answer_card %Card{data: "I like to drink {|1|}, but not without my {|2|}. Yes, {|2|}."}
  @player_card_beer %Card{data: "beer"}
  @player_card_taxes %Card{data: "taxes"}

  describe "fill/2" do
    test "it fills in a basic template" do
      assert Card.fill(@basic_card, @player_card_taxes) == "I am addicted to eating taxes"
      assert Card.fill(@basic_card, @player_card_beer) == "I am addicted to eating beer"
    end

    test "it fills a multi-answer card template" do
      assert Card.fill(@multi_answer_card, [@player_card_taxes, @player_card_beer]) ==
               "I like to drink taxes, but not without my beer. Yes, beer."

      assert Card.fill(@multi_answer_card, [@player_card_beer, @player_card_taxes]) ==
               "I like to drink beer, but not without my taxes. Yes, taxes."
    end
  end

  describe "fill_data/2" do
    test "it fills in template data with the provided strings" do
      assert Card.fill_data(@multi_answer_card.data, [{"beer", 1}, {"taxes", 2}]) ==
               "I like to drink beer, but not without my taxes. Yes, taxes."

      assert Card.fill_data(@multi_answer_card.data, [{"taxes", 1}, {"beer", 2}]) ==
               "I like to drink taxes, but not without my beer. Yes, beer."
    end
  end
end
