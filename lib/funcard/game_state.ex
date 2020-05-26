defmodule Funcard.GameState do
  use TypedStruct

  alias Funcard.Deck
  alias Funcard.Event
  alias Funcard.Player

  typedstruct enforce: true do
    field :deck, Deck.t()
    field :players, list(Player.t())
    field :round, integer(), default: 0
    field :turn, Player.id() | :nobody, default: :nobody
  end

  @spec new(Deck.t(), list(Player.t())) :: t()
  def new(deck, players) do
    %__MODULE__{
      deck: deck,
      players: players
    }
  end

  @spec apply_event(t(), Event.t()) :: t()
  def apply_event(game_state, event) do
    apply(__MODULE__, event.event, [game_state | event.args])
  end

  @spec add_player(t(), Player.t()) :: t()
  def add_player(game_state, player) do
    Map.put(game_state, :players, [player | game_state.players])
  end

  @spec start_game(t()) :: t()
  def start_game(game_state) do
    {players, player_cards} = distribute_cards(game_state.players, game_state.deck.player_cards)
    [_, table_cards] = game_state.deck.table_cards

    Map.put(game_state, :turn, List.last(game_state.players).id)
    |> Map.put(:round, game_state.round + 1)
    |> Map.put(:players, players)
    |> Map.put(
      :deck,
      Map.put(game_state.deck, :table_cards, table_cards) |> Map.put(:player_cards, player_cards)
    )
  end

  defp distribute_cards(players, player_cards) do
    distribute_cards(d_cards(players, player_cards), 0)
  end

  defp distribute_cards(response, 4), do: response

  defp distribute_cards({players, player_cards}, num) do
    distribute_cards(d_cards(players, player_cards), num + 1)
  end

  defp d_cards(players, player_cards) do
    scan =
      Enum.scan(players, {nil, player_cards}, fn x, {_, acc} ->
        Player.draw_card(x, acc)
      end)

    IO.inspect(scan)

    updated_players = Enum.map(scan, fn {x, _} -> x end)
    {_, updated_cards} = List.last(scan)
    {updated_players, updated_cards}
  end
end
