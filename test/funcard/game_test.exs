defmodule Funcard.GameTest do
  use Funcard.GameCase, async: true

  alias Funcard.{Game, GameSession}

  setup do
    {:ok, game} = Game.start([@deck1, @deck2], @player)
    [game: game]
  end

  test "start/3 instances the Game agent with a new GameSession", %{game: game} do
    assert Agent.get(game, & &1).__struct__ == GameSession
  end
end
