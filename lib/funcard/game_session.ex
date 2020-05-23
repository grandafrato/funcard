defmodule Funcard.GameSession do
  use TypedStruct

  alias Funcard.Deck
  alias Funcard.Event
  alias Funcard.GameState
  alias Funcard.Player

  typedstruct enforce: true do
    field :admin, Player.t()
    field :events, list(Event.t()), default: []
    field :initial_state, GameState.t()
  end

  @spec new(list(Deck.t()), Player.t()) :: t()
  def new(decks, player) do
    deck = List.foldr(decks, nil, fn x, acc -> Deck.merge(acc, x) end)

    %__MODULE__{
      admin: player,
      initial_state: GameState.new(deck, [player])
    }
  end

  @spec add_event(t(), struct()) :: t()
  def add_event(game, %Event{} = event) do
    events = sort_into_events(event, game.events)

    Map.put(game, :events, events)
  end

  @spec sort_into_events(Event.t(), list(Event.t())) :: list(Event.t())
  defp sort_into_events(event, []), do: [event]

  defp sort_into_events(event, events) do
    [event1 | [event2 | other_events]] = [event | events]

    if event2.timestamp <= event1.timestamp do
      [event2 | sort_into_events(event1, other_events)]
    else
      [event | events]
    end
  end
end
