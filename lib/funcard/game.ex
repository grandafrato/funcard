defmodule Funcard.Game do
  alias Funcard.{Deck, GameSession, Player}

  @spec start([Deck.t()], Player.t()) :: Agent.on_start()
  def start(decks, first_player), do: Agent.start(fn -> GameSession.new(decks, first_player) end)
end
