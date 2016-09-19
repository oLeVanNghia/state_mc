# State Machine for Ecto
State machine pattern in Ecto.

Example:

```
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

```
user = Example.Repo.get(Example.User, 1)
Example.User.current_state(user) # => get current state
Example.User.can_approve?(user)  # => check event approve
Example.User.can_reject?(user)   # => check event reject
Example.User.approve(user)       # => call event approve to change state to approved
Example.User.reject(user)        # => call event reject to change state to approved
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `state_mc` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:state_mc, "~> 0.1.0"}]
    end
    ```

  2. Ensure `state_mc` is started before your application:

    ```elixir
    def application do
      [applications: [:state_mc]]
    end
    ```

