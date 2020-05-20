defmodule Funcard.Deck do
  use TypedStruct
  alias Funcard.Deck.Card

  @derive Jason.Encoder

  @moduledoc """
  Manages decks and shuffles them.
  """

  typedstruct do
    field :name, String.t()
    field :player_cards, [Card.t()]
    field :table_cards, [Card.t()]
  end

  @doc """
  Shuffles the `:player_cards` and `:table_cards` fields of a deck.

  ## Example

      iex> table_cards = [%Funcard.Deck.Card{data: "1 {||}"}, %Funcard.Deck.Card{data: "2 {||}"}, %Funcard.Deck.Card{data: "3 {||}"}]
      iex> player_cards = [%Funcard.Deck.Card{data: "Foo"}, %Funcard.Deck.Card{data: "Bar"}, %Funcard.Deck.Card{data: "Baz"}]
      iex> deck = %Funcard.Deck{name: "Foo Deck", player_cards: player_cards, table_cards: table_cards}
      iex> Funcard.Deck.shuffle(deck)
      %Funcard.Deck{
        name: "Foo Deck",
        player_cards: [
          %Funcard.Deck.Card{data: "Baz"},
          %Funcard.Deck.Card{data: "Foo"},
          %Funcard.Deck.Card{data: "Bar"}
        ],
        table_cards: [
          %Funcard.Deck.Card{data: "1 {||}"},
          %Funcard.Deck.Card{data: "3 {||}"},
          %Funcard.Deck.Card{data: "2 {||}"}
        ]
      }

  """
  @spec shuffle(t()) :: t()
  def shuffle(%{player_cards: player_cards, table_cards: table_cards} = deck) do
    shuffled_player_cards = Enum.shuffle(player_cards)
    shuffled_table_cards = Enum.shuffle(table_cards)

    deck
    |> Map.put(:player_cards, shuffled_player_cards)
    |> Map.put(:table_cards, shuffled_table_cards)
  end
end
