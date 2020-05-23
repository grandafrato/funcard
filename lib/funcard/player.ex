defmodule Funcard.Player do
  use TypedStruct
  alias Funcard.Deck.Card

  @moduledoc """
  Represents a player in the game.
  """

  typedstruct do
    field :name, String.t(), enforce: true
    field :hand, [Card.t()], default: []
    field :cards_won, [Card.t()], default: []
    field :admin?, boolean(), default: false
  end

  @doc """
  Plays a card by returning a tuple of the card played and a player without
  that card in its `hand` field.

  **Note that the index starts at 1 to match the template system.**

  ## Example

      iex> hand = [%Funcard.Deck.Card{data: "foo"}, %Funcard.Deck.Card{data: "bar"}, %Funcard.Deck.Card{data: "baz"}]
      iex> player = %Funcard.Player{name: "Dave", hand: hand}
      iex> Funcard.Player.play_card(player, 2)
      {%Funcard.Deck.Card{data: "bar"},
       %Funcard.Player{
         admin?: false,
         cards_won: [],
         hand: [%Funcard.Deck.Card{data: "foo"}, %Funcard.Deck.Card{data: "baz"}],
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

      iex> %Funcard.Player{name: "Dave"}
      ...> |> Funcard.Player.win_card(%Funcard.Deck.Card{data: "I'm currently eating {||}"})
      %Funcard.Player{
        admin?: false,
        cards_won: [%Funcard.Deck.Card{data: "I'm currently eating {||}"}],
        hand: [],
        name: "Dave"
      }

  """
  @spec win_card(t(), Card.t()) :: t()
  def win_card(player, card) do
    Map.put(player, :cards_won, [card | player.cards_won])
  end

  @doc """
  Sets the given player to an admin.

  ## Example

      iex> player = %Funcard.Player{name: "Foo"}
      iex> Funcard.Player.set_admin(player)
      %Funcard.Player{
        admin?: true,
        cards_won: [],
        hand: [],
        name: "Foo"
      }

  """
  @spec set_admin(t()) :: t()
  def set_admin(player) do
    Map.put(player, :admin?, true)
  end
end
