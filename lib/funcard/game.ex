defmodule Funcard.Game do
  use GenServer

  alias Funcard.Deck

  @moduledoc """
  d
  """

  @spec start_link(list({:deck, Deck.t()})) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    {:ok, opts}
  end
end
