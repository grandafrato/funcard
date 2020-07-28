defmodule Funcard.GameSession do
  use TypedStruct

  alias Funcard.Deck
  alias Funcard.Event
  alias Funcard.GameState
  alias Funcard.Player

  typedstruct enforce: true do
    field :admin, Player.id()
    field :current_state, GameState.t(), enforce: false
    field :events, list(Event.t()), default: []
    field :initial_state, GameState.t()
  end

  @doc """
  Generates a new Funcard.GameSession.

  Has the option to be shuffle the deck, which is set to true by default.

  ## Example

      iex> deck = %Funcard.Deck{
      ...>   name: "Foo Deck",
      ...>   player_cards: [
      ...>     %Funcard.Deck.Card{data: "fasd"},
      ...>     %Funcard.Deck.Card{data: "lololololo"},
      ...>     %Funcard.Deck.Card{data: "feet"}
      ...>   ],
      ...>   table_cards: [
      ...>     %Funcard.Deck.Card{data: "1 {||}"},
      ...>     %Funcard.Deck.Card{data: "2 {||}"},
      ...>     %Funcard.Deck.Card{data: "3 {||}"}
      ...>   ]
      ...> }
      iex> player = %Funcard.Player{name: "tod", id: ""}
      iex> Funcard.GameSession.new([deck], player, shuffle?: false)
      %GameSession{
        admin: "",
        events: [],
        initial_state: %Funcard.GameState{
          deck: %Funcard.Deck{
            name: "Foo Deck",
            player_cards: [
              %Funcard.Deck.Card{data: "fasd"},
              %Funcard.Deck.Card{data: "lololololo"},
              %Funcard.Deck.Card{data: "feet"}
            ],
            table_cards: [
              %Funcard.Deck.Card{data: "1 {||}"},
              %Funcard.Deck.Card{data: "2 {||}"},
              %Funcard.Deck.Card{data: "3 {||}"}
            ]
          },
          players: [
            %Funcard.Player{
              cards_won: [],
              hand: [],
              id: "",
              name: "tod"
            }
          ],
          round: 0,
          turn: :nobody
        }
      }

  """
  @spec new(list(Deck.t()), Player.t(), shuffle?: boolean()) :: t()
  def new(decks, player, [shuffle?: shuffle?] \\ [shuffle?: true]) do
    deck =
      if shuffle? do
        List.foldr(decks, nil, fn x, acc -> Deck.merge(acc, x) |> Deck.shuffle() end)
      else
        List.foldr(decks, nil, fn x, acc -> Deck.merge(acc, x) end)
      end

    %__MODULE__{
      admin: player.id,
      initial_state: GameState.new(deck, [player])
    }
  end

  @doc """
  Sorts the given event into the given event list.
  """
  @spec add_event(t(), struct()) :: t()
  def add_event(game, %Event{} = event) do
    events = sort_into_events(event, game.events)

    Map.put(game, :events, events)
  end

  @spec apply_events(t()) :: t()
  def apply_events(game) do
    Map.put(
      game,
      :current_state,
      List.foldl(game.events, game.initial_state, &GameState.apply_event(&2, &1))
    )
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
