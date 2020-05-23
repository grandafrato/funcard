defmodule Funcard.Event do
  use TypedStruct

  typedstruct enforce: true do
    field :event, atom()
    field :args, list(any())
    field :timestamp, DateTime.t()
  end

  @spec new(atom(), list(any())) :: t()
  def new(event, args) do
    %__MODULE__{
      event: event,
      args: args,
      timestamp: DateTime.utc_now()
    }
  end
end
