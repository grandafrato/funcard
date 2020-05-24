defmodule Funcard.Event do
  use TypedStruct

  alias Funcard.Deck.Card
  alias Funcard.Player

  @type event_arg() :: Player.t() | Card.t()

  typedstruct enforce: true do
    field :args, list(event_arg())
    field :event, atom()
    field :timestamp, DateTime.t()
  end

  @doc """
  Creates a new event timestamped with the current time in utc.
  """
  @spec new(atom(), list(event_arg())) :: t()
  def new(event, args) do
    %__MODULE__{
      event: event,
      args: args,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Generates the event that adds a player. The event can only be added
  successfully if it is round 0.
  """
  @spec add_player(Player.t()) :: t()
  def add_player(player), do: new(:add_player, [player])

  @doc """
  Generates the event that ends a game. The event will only work if the given
  player is the session administrator.
  """
  @spec end_game(Player.t()) :: t()
  def end_game(player), do: new(:end_game, [player])

  @doc """
  Generates the event that ends a round. The first argument is the table_master
  and the second is the winner of the round.
  """
  @spec end_round(Player.t(), Player.t()) :: t()
  def end_round(table_master, winner), do: new(:end_round, [table_master, winner])

  @doc """
  Gnerates the event that makes a player play the selected card.
  """
  @spec play_card(Player.t(), Card.t()) :: t()
  def play_card(player, card), do: new(:play_card, [player, card])

  @doc """
  Generates the event for when a player quits.
  """
  @spec quit_player(Player.t()) :: t()
  def quit_player(player), do: new(:quit_player, [player])

  @doc """
  Generates the event that starts the game. The event will only work if the
  given player is the session administrator.
  """
  @spec start_game(Player.t()) :: t()
  def start_game(player), do: new(:start_game, [player])
end
