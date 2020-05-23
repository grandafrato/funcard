defmodule Funcard.Game do
  use TypedStruct

  alias Funcard.Deck
  alias Funcard.Event
  alias Funcard.Player

  typedstruct do
    field :deck, Deck.t(), enforce: true
    field :events, list(Event.t()), default: []
    field :players, list(Player.t()), enforce: true
    field :round, non_neg_integer(), default: 0
  end

  @spec new(list(Deck.t()), Player.t()) :: t()
  def new(decks, player) do
    deck = List.foldr(decks, nil, fn x, acc -> Deck.merge(acc, x) end)

    %__MODULE__{
      deck: deck,
      players: [Player.set_admin(player)]
    }
  end

  @spec add_event(t(), struct()) :: t()
  def add_event(game, %Event{} = event) do
    events =
      if [_event2 | [_event1 | _]] |> match?([event | game.events]) do
        [event2 | [event1 | _]] = [event | game.events]

        if event2.timestamp < event1.timestamp do
          Enum.sort_by([event | game.events], fn x -> x.timestamp end)
        else
          [event | game.events]
        end
      else
        [event | game.events]
      end

    Map.put(game, :events, events)
  end
end
