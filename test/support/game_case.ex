defmodule Funcard.GameCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @hand [%Funcard.Deck.Card{data: "bar"}, %Funcard.Deck.Card{data: "baz"}]
      @deck1 %Funcard.Deck{
        name: "Foo Deck",
        player_cards: [
          %Funcard.Deck.Card{data: "fasd"},
          %Funcard.Deck.Card{data: "lololololo"},
          %Funcard.Deck.Card{data: "feet"}
          | @hand
        ],
        table_cards: [
          %Funcard.Deck.Card{data: "1 {||}"},
          %Funcard.Deck.Card{data: "2 {||}"},
          %Funcard.Deck.Card{data: "3 {||}"}
        ]
      }
      @deck2 %Funcard.Deck{
        name: "Bar Deck",
        player_cards: [
          %Funcard.Deck.Card{data: "slom"},
          %Funcard.Deck.Card{data: "*cries*"},
          %Funcard.Deck.Card{data: "toes"},
          %Funcard.Deck.Card{data: "bananana"},
          %Funcard.Deck.Card{data: "Craig"},
          %Funcard.Deck.Card{data: "pizza"},
          %Funcard.Deck.Card{data: "lizard"}
        ],
        table_cards: [
          %Funcard.Deck.Card{data: "one {||}"},
          %Funcard.Deck.Card{data: "two {||}"},
          %Funcard.Deck.Card{data: "three {||}"}
        ]
      }
      @player Funcard.Player.new("Foo")
    end
  end
end
