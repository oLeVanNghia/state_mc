defmodule StateMc do
  @moduledoc """
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
  Example.User.reject(user)        # => call event reject to change state to rejected
  ```
  """
  defmodule EctoSm do
    defmacro statemc(column, body) do
      quote do
        alias Ecto.Changeset
        def smc_column() do
          unquote(column)
        end

        def current_state(record) do
          case record |> Map.fetch(smc_column()) do
            {:ok, state} -> String.to_atom(state)
            _ -> nil
          end
        end

        def validate_state_transition(changeset, from_states, to_state) do
          cr_state = current_state(changeset.data)
          if Enum.member?(from_states, cr_state) && state_defined?(to_state) do
            changeset
          else
            changeset
            |> Changeset.add_error(smc_column(),
              "You can't move state from :#{cr_state} to :#{to_state}")
          end
        end

        unquote(body[:do])
      end
    end

    defmacro defstate(states) do
      quote do
        def states() do
          unquote(states)
        end

        def state_defined?(state) do
          states()
          |> Enum.member?(state)
        end
      end
    end

    defmacro defevent(event, options, callback) do
      quote do
        alias Ecto.Changeset
        def unquote(:"#{event}")(record) do
          %{from: from_states, to: to_state} = unquote(options)
          record
          |> Changeset.change(%{smc_column() => Atom.to_string(to_state)})
          |> validate_state_transition(from_states, to_state)
          |> unquote(callback).()
        end

        def unquote(:"can_#{event}?")(record) do
          %{from: from_states, to: to_state} = unquote(options)
          cr_state = current_state(record)
          Enum.member?(from_states, cr_state) && state_defined?(to_state)
        end
      end
    end
  end
end
