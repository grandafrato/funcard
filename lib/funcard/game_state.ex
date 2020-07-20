defmodule Funcard.GameState do
  use TypedStruct

  alias Funcard.Deck
  alias Funcard.Event
  alias Funcard.Player

  typedstruct enforce: true do
    field :card_in_play, Deck.Card.t(), enforce: false
    field :deck, Deck.t()
    field :played_cards, list({Player.id(), Deck.Card.t()}), default: []
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

  @spec play_card(t(), Player.id(), integer()) :: t()
  def play_card(game_state, player_id, card_id) do
    {card, player} =
      game_state.players
      |> Enum.find(&(&1.id == player_id))
      |> Player.play_card(card_id)

    {first_half, [_ | second_half]} =
      Enum.split(game_state.players, Enum.find_index(game_state.players, &(&1.id == player_id)))

    game_state
    |> Map.put(:players, first_half ++ [player | second_half])
    |> Map.put(:played_cards, [{player_id, card} | game_state.played_cards])
  end

  @spec start_game(t()) :: t()
  def start_game(game_state) do
    {players, player_cards} = distribute_cards(game_state.players, game_state.deck.player_cards)
    [card_in_play | table_cards] = game_state.deck.table_cards

    game_state
    |> Map.put(:turn, List.last(game_state.players).id)
    |> Map.put(:round, game_state.round + 1)
    |> Map.put(:players, players)
    |> Map.put(
      :deck,
      Map.put(game_state.deck, :table_cards, table_cards) |> Map.put(:player_cards, player_cards)
    )
    |> Map.put(:card_in_play, card_in_play)
  end

  defp distribute_cards(players, player_cards) do
    chunked = Enum.chunk_every(player_cards, Enum.count(players))

    new_cards_for_player =
      Enum.map(1..Enum.count(players), fn x ->
        Enum.map(chunked, fn y -> Enum.fetch!(y, x - 1) end)
      end)
      |> Enum.map(fn x -> Enum.take(x, 5) end)

    mapped_players =
      players
      |> Enum.map(fn x ->
        Enum.map(new_cards_for_player, fn y -> Map.put(x, :hand, y) end)
      end)

    updated_players =
      mapped_players
      |> Enum.with_index()
      |> Enum.map(fn {players, index} ->
        Enum.fetch!(players, index)
      end)

    updated_player_cards = Enum.take(player_cards, -Enum.count(players))

    {updated_players, updated_player_cards}
  end
end
