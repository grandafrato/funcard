defmodule Funcard.Event do
  use TypedStruct

  typedstruct enforce: true do
    field :event, atom()
    field :args, list(any())
    field :timestamp, integer()
  end

  @spec new(atom(), list(any())) :: t()
  def new(event, args) do
    %__MODULE__{
      event: event,
      args: args,
      timestamp: DateTime.utc_now() |> DateTime.to_unix()
    }
  end
end
