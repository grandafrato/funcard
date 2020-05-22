defmodule Funcard.GameTest do
  use ExUnit.Case

  alias Funcard.Deck
  alias Funcard.Deck.Card
  alias Funcard.Game
  alias Funcard.Player

  @played_card %Card{data: "foo"}
  @hand [@played_card, %Card{data: "bar"}, %Card{data: "baz"}]
  @deck1 %Deck{
    name: "Foo Deck",
    player_cards: [%Card{data: "fasd"}, %Card{data: "lololololo"}, %Card{data: "feet"} | @hand],
    table_cards: [%Card{data: "1 {||}"}, %Card{data: "2 {||}"}, %Card{data: "3 {||}"}]
  }
  @deck2 %Deck{
    name: "Bar Deck",
    player_cards: [%Card{data: "slom"}, %Card{data: "*cries*"}, %Card{data: "toes"} | @hand],
    table_cards: [%Card{data: "one {||}"}, %Card{data: "two {||}"}, %Card{data: "three {||}"}]
  }

  setup do
    {:ok, pid} = Game.start_link(decks: [@deck1, @deck2])
    {:ok, pid: pid}
  end

  describe "initialization" do
    test "the initial game has all the decks merged into one", %{pid: pid} do
      %Deck{player_cards: game_player_cards, table_cards: game_table_cards} = Game.get_deck(pid)

      assert Enum.all?(game_player_cards, fn x ->
               Enum.member?(@deck1.player_cards, x) or Enum.member?(@deck2.player_cards, x)
             end)

      assert Enum.all?(game_table_cards, fn x ->
               Enum.member?(@deck1.table_cards, x) or Enum.member?(@deck2.table_cards, x)
             end)
    end

    test "the cards are shuffled", %{pid: pid} do
      deck = Game.get_deck(pid)

      assert deck != @deck1 and deck != @deck2
    end
  end

  describe "addition of players" do
    test "add first player", %{pid: pid} do
      Game.add_player(pid, %Player{
        name: "foo",
        pid:
          spawn(fn ->
            receive do
              {:player_added, player} -> player
            end
          end)
      })

      assert %Player{name: "foo"} |> match?(Game.get_player_by_name(pid, "foo"))
    end

    test "adding the same player twice will not duplicate it", %{pid: pid} do
      Game.add_player(pid, %Player{
        name: "foo",
        pid:
          spawn(fn ->
            receive do
              {:player_added, player} -> player
            end
          end)
      })

      Game.add_player(pid, %Player{
        name: "foo",
        pid:
          spawn(fn ->
            receive do
              {:player_added, player} -> player
            end
          end)
      })

      players = Game.get_players(pid)

      assert players == Enum.dedup(players)
    end

    test "adding a player with the same name will replace it", %{pid: pid} do
      Game.add_player(pid, %Player{
        name: "foo",
        pid:
          spawn(fn ->
            receive do
              {:player_added, player} -> player
            end
          end)
      })

      player1 = Game.get_player_by_name(pid, "foo")

      Game.add_player(pid, %Player{
        name: "foo",
        pid:
          spawn(fn ->
            receive do
              {:player_added, player} -> player
            end
          end),
        hand: @hand
      })

      player2 = Game.get_player_by_name(pid, "foo")

      assert player1 != player2
    end
  end
end
