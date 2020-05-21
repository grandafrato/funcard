defmodule Funcard.GameTest do
  use ExUnit.Case, async: true

  alias Funcard.Deck
  alias Funcard.Deck.Card
  alias Funcard.Game
  alias Funcard.Player

  @played_card %Card{data: "foo"}
  @hand [@played_card, %Card{data: "bar"}, %Card{data: "baz"}]
  @deck %Deck{
    name: "Foo Deck",
    player_cards: [%Card{data: "fasd"}, %Card{data: "lololololo"}, %Card{data: "feet"} | @hand],
    table_cards: [%Card{data: "1 {||}"}, %Card{data: "2 {||}"}, %Card{data: "3 {||}"}]
  }

  setup do
    {:ok, pid} = Game.start_link(deck: @deck)

    player = %Player{
      name: "Jasean",
      pid:
        spawn(fn ->
          receive do
            {from, x} ->
              send(from, {:player_received, x})
          end
        end),
      hand: @hand
    }

    {:ok, [pid: pid, player: player]}
  end

  describe "get_state/1" do
    test "the initial" do
    end
  end
end
