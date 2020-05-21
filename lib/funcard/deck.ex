defmodule Funcard.Deck do
  use TypedStruct
  alias Funcard.Deck.Card

  @derive Jason.Encoder

  @moduledoc """
  Manipulates `%Funcard.Deck{}` structs.
  """

  typedstruct do
    field :name, String.t(), enforce: true
    field :player_cards, list(Card.t()), default: []
    field :table_cards, list(Card.t()), default: []
  end

  @doc """
  Shuffles the `:player_cards` and `:table_cards` fields of a deck in a random
  order.

  ## Example

      iex> table_cards = [
      ...>   %Funcard.Deck.Card{data: "1 {||}"},
      ...>   %Funcard.Deck.Card{data: "2 {||}"},
      ...>   %Funcard.Deck.Card{data: "3 {||}"}
      ...> ]
      iex> player_cards = [
      ...>   %Funcard.Deck.Card{data: "Foo"},
      ...>   %Funcard.Deck.Card{data: "Bar"},
      ...>   %Funcard.Deck.Card{data: "Baz"}
      ...> ]
      iex> deck = %Funcard.Deck{
      ...>   name: "Foo Deck",
      ...>   player_cards: player_cards,
      ...>   table_cards: table_cards
      ...> }
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

  @doc """
  Merges two different decks into one.

  ## Example

      iex> player_cards = [
      ...>   %Funcard.Deck.Card{data: "card 1"},
      ...>   %Funcard.Deck.Card{data: "card 2"},
      ...>   %Funcard.Deck.Card{data: "card 3"},
      ...>   %Funcard.Deck.Card{data: "card 4"}
      ...> ]
      iex> table_cards = [
      ...>   %Funcard.Deck.Card{data: "{||} 1"},
      ...>   %Funcard.Deck.Card{data: "{||} 2"},
      ...>   %Funcard.Deck.Card{data: "{||} 3"},
      ...>   %Funcard.Deck.Card{data: "{||} 4"}
      ...> ]
      iex> deck1 = %Funcard.Deck{
      ...>   name: "Deck1",
      ...>   player_cards: player_cards, 
      ...>   table_cards: table_cards
      ...> }
      iex> deck2 = %Funcard.Deck{
      ...>   name: "Deck2",
      ...>   player_cards: [%Funcard.Deck.Card{data: "not good card"}],
      ...>   table_cards: [%Funcard.Deck.Card{data: "{||} oof"}]
      ...> }
      iex> Funcard.Deck.merge(deck1, deck2)
      %Funcard.Deck{
        name: "Deck1 + Deck2",
        player_cards: [
          %Funcard.Deck.Card{data: "not good card"},
          %Funcard.Deck.Card{data: "card 1"},
          %Funcard.Deck.Card{data: "card 2"},
          %Funcard.Deck.Card{data: "card 3"},
          %Funcard.Deck.Card{data: "card 4"}
        ],
        table_cards: [
          %Funcard.Deck.Card{data: "{||} oof"},
          %Funcard.Deck.Card{data: "{||} 1"},
          %Funcard.Deck.Card{data: "{||} 2"},
          %Funcard.Deck.Card{data: "{||} 3"},
          %Funcard.Deck.Card{data: "{||} 4"}
        ]
      }

  """
  @spec merge(t(), t()) :: t()
  def merge(deck1, deck2) do
    %__MODULE__{
      name: "#{deck1.name} + #{deck2.name}",
      player_cards: Enum.concat(deck2.player_cards, deck1.player_cards),
      table_cards: Enum.concat(deck2.table_cards, deck1.table_cards)
    }
  end
end
