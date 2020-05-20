defmodule Funcard.Deck.Card do
  use TypedStruct

  @derive Jason.Encoder

  typedstruct do
    field :data, String.t(), enforce: true
  end

  def fill(table_card, player_cards) when is_list(player_cards) do
    indexed_cards_data = Enum.map(player_cards, & &1.data) |> Enum.with_index(1)
    fill_data(table_card.data, indexed_cards_data)
  end

  def fill(table_card, player_card),
    do: String.replace(table_card.data, ~r/\{\|.*\|\}/, player_card.data)

  def fill_data(table_card_data, []), do: table_card_data

  def fill_data(table_card_data, [{selected_card, position} | other_cards]) do
    String.replace(table_card_data, "{|#{position}|}", selected_card)
    |> fill_data(other_cards)
  end
end
