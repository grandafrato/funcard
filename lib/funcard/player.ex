defmodule Funcard.Player do
  use TypedStruct
  alias Funcard.Deck.Card

  @moduledoc """
  Represents a player in the game.
  """

  @type id() :: String.t()

  typedstruct do
    field :cards_won, [Card.t()], default: []
    field :hand, [Card.t()], default: []
    field :id, id(), enforce: true
    field :name, String.t(), enforce: true
  end

  def draw_card(player, player_cards) do
    {card, leftover_cards} = List.pop_at(player_cards, 0)
    {Map.put(player, :hand, [card | player.hand]), leftover_cards}
  end

  def draw_card({player, player_cards}), do: draw_card(player, player_cards)

  @doc """
  Generates a new player with the given name, a random id and an optionally
  given hand.
  """
  @spec new(String.t(), [Card.t()]) :: t()
  def new(name, hand \\ []) do
    %__MODULE__{
      hand: hand,
      id: UUID.uuid1(),
      name: name
    }
  end

  @doc """
  Plays a card by returning a tuple of the card played and a player without
  that card in its `hand` field.

  **Note that the index starts at 1 to match the template system.**

  ## Example

      iex> hand = [%Funcard.Deck.Card{data: "foo"}, %Funcard.Deck.Card{data: "bar"}, %Funcard.Deck.Card{data: "baz"}]
      iex> player = %Funcard.Player{name: "Dave", hand: hand, id: ""}
      iex> Funcard.Player.play_card(player, 2)
      {%Funcard.Deck.Card{data: "bar"},
       %Funcard.Player{
         cards_won: [],
         hand: [%Funcard.Deck.Card{data: "foo"}, %Funcard.Deck.Card{data: "baz"}],
         id: "",
         name: "Dave"
       }}

  """
  @spec play_card(t(), pos_integer) :: {Card.t(), t()}
  def play_card(%__MODULE__{hand: hand} = player, cardid) do
    {card, new_hand} = List.pop_at(hand, cardid - 1)
    {card, Map.put(player, :hand, new_hand)}
  end

  @doc """
  Has the player win a card by putting the card into the `cards_won` field.

  ## Example

      iex> %Funcard.Player{name: "Dave", id: ""}
      ...> |> Funcard.Player.win_card(%Funcard.Deck.Card{data: "I'm currently eating {||}"})
      %Funcard.Player{
        cards_won: [%Funcard.Deck.Card{data: "I'm currently eating {||}"}],
        hand: [],
        id: "",
        name: "Dave"
      }

  """
  @spec win_card(t(), Card.t()) :: t()
  def win_card(player, card) do
    Map.put(player, :cards_won, [card | player.cards_won])
  end
end
