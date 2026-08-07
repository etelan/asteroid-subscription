require "rails_helper"

RSpec.describe User do
  describe "validations" do
    it "normalizes email to lowercase before validation" do
      user = build(
        :user,
        email: "TeSt@Example.COM"
      )

      user.validate

      expect(user.email).to eq("test@example.com")
    end

    it "enforces case-insensitive email uniqueness" do
      create(:user, email: "existing@example.com")
      duplicate = build(
        :user,
        email: "EXISTING@example.com"
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end
  end
end
