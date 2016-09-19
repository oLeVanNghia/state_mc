defmodule Dummy.User do
  use Dummy.Web, :model
  import StateMc.EctoSm

  schema "users" do
    field :state, :string, default: "waiting"
  end

  statemc :state do
    defstate [:waiting, :approved, :rejected]
    defevent :approve, %{from: [:waiting, :rejected], to: :approved}, fn(changeset) ->
      changeset
    end
    defevent :reject, %{from: [:waiting, :approved], to: :rejected}, fn(changeset) ->
      changeset
    end
  end
end
