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
    events =
      if [_event2 | [_event1 | _]] |> match?([event | game.events]) do
        [event2 | [event1 | other_events]] = [event | game.events]

        if event2.timestamp < event1.timestamp do
          [event1 | [event2 | other_events]]
        else
          [event | game.events]
        end
      else
        [event | game.events]
      end

    Map.put(game, :events, events)
  end
end
