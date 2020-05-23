defmodule Funcard.GameState do
  use TypedStruct

  alias Funcard.Deck
  alias Funcard.Player

  typedstruct enforce: true do
    field :deck, Deck.t()
    field :players, list(Player.t())
    field :round, integer(), default: 0
    field :turn, Player.t() | :nobody, default: :nobody
  end

  @spec new(Deck.t(), list(Player.t())) :: t()
  def new(deck, players) do
    %__MODULE__{
      deck: deck,
      players: players
    }
  end
end
