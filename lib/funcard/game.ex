defmodule Funcard.Game do
  use GenServer

  alias Funcard.Deck
  alias Funcard.Player

  @moduledoc """
  """

  # Client Facing API

  @spec start_link(list({:deck, Deck.t()})) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @spec get_deck(pid()) :: Deck.t()
  def get_deck(pid) do
    GenServer.call(pid, :get_deck)
  end

  @spec add_player(pid(), Player.t()) :: :ok
  def add_player(pid, player) do
    GenServer.cast(pid, {:add_player, player})
  end

  @spec get_player_by_name(pid(), String.t()) :: Player.t()
  def get_player_by_name(pid, name) do
    GenServer.call(pid, {:get_player_by_name, name})
  end

  @spec get_players(pid()) :: list(Player.t())
  def get_players(pid) do
    GenServer.call(pid, :get_players)
  end

  # GenServer Backend

  @impl true
  def init(decks: decks) do
    deck =
      List.foldr(decks, nil, fn x, acc ->
        Deck.merge(acc, x)
        |> Deck.shuffle()
      end)

    {:ok, %__MODULE__.Struct{deck: deck}}
  end

  @impl true
  def handle_call(:get_deck, _from, %{deck: deck} = state) do
    {:reply, deck, state}
  end

  @impl true
  def handle_call({:get_player_by_name, name}, _from, %{players: players} = state) do
    [player | _] = Enum.filter(players, fn x -> Map.fetch(x, name) end)
    {:reply, player, state}
  end

  @impl true
  def handle_call(:get_players, _from, state) do
    {:reply, state.players, state}
  end

  @impl true
  def handle_cast({:add_player, player}, state) do
    {:noreply, Map.put(state, :players, [player | state.players])}
  end
end
