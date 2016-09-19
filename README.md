# State Machine for Ecto
State machine pattern in Ecto.

## Installation

The package can be installed as:

  1. Add `state_mc` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:state_mc, "~> 0.1.0"}]
    end
    ```

## How to use?
Example:

```elixir
defmodule Example.User do
  use Example.Web, :model

  import StateMc.EctoSm

  schema "users" do
    field :state, :string, default: "waiting"
  end

  statemc :state do
    defstate [:waiting, :approved, :rejected]
    defevent :approve, %{from: [:waiting, :rejected], to: :approved}, fn(changeset) ->
      changeset
      |> Example.Repo.update()
    end
    defevent :reject, %{from: [:waiting, :approved], to: :rejected}, fn(changeset) ->
      changeset
      |> Example.Repo.update()
    end
  end
end
```

## How to run?

```elixir
user = Example.Repo.get(Example.User, 1)
Example.User.current_state(user) # => get current state
Example.User.can_approve?(user)  # => check event approve
Example.User.can_reject?(user)   # => check event reject
Example.User.approve(user)       # => call event approve to change state to approved
Example.User.reject(user)        # => call event reject to change state to rejected
```


