defmodule Funcard.Deck.Card do
  use TypedStruct

  @moduledoc """
  Manages `Card`s and fills table cards with the data of a player card.

  The template format for the table cards is a `{|` and a `|}`, with either
  the number associated to the player card or nothing at all between them.
  """

  @derive Jason.Encoder

  typedstruct do
    field :data, String.t(), enforce: true
  end

  @doc """
  Fills the table card with the provided table cards.

  ## Examples

  When the function recieves a list of player cards, it fills the table card's
  template with the associated player card based on its index.

      iex> player_cards = [%Funcard.Deck.Card{data: "foo"}, %Funcard.Deck.Card{data: "bar"}, %Funcard.Deck.Card{data: "baz"}]
      iex> table_card = %Funcard.Deck.Card{data: "I love to eat {|1|}, but when {|3|} or {|2|} is involved I hate {|1|}."}
      iex> Funcard.Deck.Card.fill(table_card, player_cards)
      "I love to eat foo, but when baz or bar is involved I hate foo."

  When the function recieves just one player card, it fills every template mark
  with the same data.

      iex> player_card = %Funcard.Deck.Card{data: "foo"}
      iex> table_card = %Funcard.Deck.Card{data: "I love to eat {|1|}, but when {|3|} or {|2|} is involved I hate {|1|}."}
      iex> Funcard.Deck.Card.fill(table_card, player_card)
      "I love to eat foo, but when foo or foo is involved I hate foo."

  """
  @spec fill(t(), [t(), ...]) :: String.t()
  def fill(table_card, player_cards) when is_list(player_cards) do
    indexed_cards_data = Enum.map(player_cards, & &1.data) |> Enum.with_index(1)
    fill_data(table_card.data, indexed_cards_data)
  end

  @spec fill(t(), t()) :: String.t()
  def fill(table_card, player_card),
    do: String.replace(table_card.data, ~r/\{\|\d*\|\}/, player_card.data)

  @doc """
  Intended mostly for internal use, this function recursively fills a template
  string with each string in the provided list of tuples.

  It does so based on the number each string is paired with. Unlike `fill/2`,
  the template mark must have a positive number.

  ## Example

      iex> Funcard.Deck.Card.fill_data("Oops, I ate too many {|1|} with my {|2|}!", [{"s**t stains", 1}, {"friends", 2}])
      "Oops, I ate too many s**t stains with my friends!"

  """
  @spec fill_data(String.t(), [{String.t(), pos_integer()}]) :: String.t()
  def fill_data(table_card_data, []), do: table_card_data

  def fill_data(table_card_data, [{selected_card, position} | other_cards]) do
    String.replace(table_card_data, "{|#{position}|}", selected_card)
    |> fill_data(other_cards)
  end
end
