defmodule Funcard.Game.Struct do
  use TypedStruct

  alias Funcard.Deck
  alias Funcard.Player

  typedstruct do
    field :deck, Deck.t()
    field :players, list(Player.t()), default: []
  end
end
