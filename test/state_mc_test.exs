defmodule StateMcTest do
  use ExUnit.Case
  use ExSpec
  alias Dummy.User
  import Dummy.Factories
  doctest StateMc

  setup_all do
    {
      :ok,
      waiting_user: insert(:user, %{ state: "waiting" }),
      approved_user: insert(:user, %{ state: "approved" }),
      rejected_user: insert(:user, %{ state: "rejected" })
    }
  end

  describe "#smc_column" do
    it "state column" do
      column = User.smc_column()
      assert column == :state
    end
  end

  describe "#current_state" do
    it "waiting state", context do
      state = context[:waiting_user] |> User.current_state
      assert state == :waiting
    end

    it "approved state", context do
      state = context[:approved_user] |> User.current_state
      assert state == :approved
    end

    it "rejected state", context do
      state = context[:rejected_user] |> User.current_state
      assert state == :rejected  
    end
  end

  describe "#validate_state_transition" do
    it "valid state transition", context do
      changeset = context[:waiting_user]
        |> Ecto.Changeset.change(%{ state: "approved" })
        |> User.validate_state_transition([:waiting, :rejected], :approved)

      assert changeset.valid? == true
      assert changeset.changes.state == "approved"
    end

    it "invalid state transition", context do
      changeset = context[:approved_user]
        |> Ecto.Changeset.change(%{ state: "approved" })
        |> User.validate_state_transition([:waiting, :rejected], :approved)

      assert changeset.valid? == false
      assert changeset.errors == [state: 
        {"You can't move state from :approved to :approved", []}]
    end
  end

  describe "#states" do
    it "states" do
      assert User.states == [:waiting, :approved, :rejected]
    end
  end

  describe "#state_defined?" do
    it "defined waiting state" do
      assert User.state_defined?(:waiting) == true
    end

    it "defined approved state" do
      assert User.state_defined?(:approved) == true
    end

    it "defined rejected state" do
      assert User.state_defined?(:rejected) == true
    end

    it "undefined dummy state" do
      assert User.state_defined?(:dummy) == false
    end
  end

  context "events" do
    describe "#approve" do
      it "waiting user can approve", context do
        changeset = User.approve(context[:waiting_user])
        assert changeset.valid? == true
        assert changeset.changes.state == "approved"
      end

      it "approved user cannot approve", context do
        changeset = User.approve(context[:approved_user])
        assert changeset.valid? == false
        assert changeset.errors == [state: 
          {"You can't move state from :approved to :approved", []}]
      end

      it "rejected user can approve", context do
        changeset = User.approve(context[:rejected_user])
        assert changeset.valid? == true
        assert changeset.changes.state == "approved"
      end
    end

    describe "#reject" do
      it "waiting user can reject", context do
        changeset = User.reject(context[:waiting_user])
        assert changeset.valid? == true
        assert changeset.changes.state == "rejected"
      end

      it "approved user can reject", context do
        changeset = User.reject(context[:approved_user])
        assert changeset.valid? == true
        assert changeset.changes.state == "rejected"
      end

      it "rejected user can approve", context do
        changeset = User.reject(context[:rejected_user])
        assert changeset.valid? == false
        assert changeset.errors == [state: 
          {"You can't move state from :rejected to :rejected", []}]
      end
    end
  end

  context "#can_*?" do
    describe "#can_approve?" do
      it "waiting user can approve", context do
        user = context[:waiting_user]
        assert User.can_approve?(user) == true
      end

      it "approved user cannot approve", context do
        user = context[:approved_user]
        assert User.can_approve?(user) == false
      end

      it "rejected user can approve", context do
        user = context[:rejected_user]
        assert User.can_approve?(user) == true
      end
    end

    describe "#can_reject?" do
      it "waiting user can reject", context do
        user = context[:waiting_user]
        assert User.can_reject?(user) == true
      end

      it "approved user can reject", context do
        user = context[:approved_user]
        assert User.can_reject?(user) == true
      end

      it "rejected user cannot reject", context do
        user = context[:rejected_user]
        assert User.can_reject?(user) == false
      end
    end
  end
end
