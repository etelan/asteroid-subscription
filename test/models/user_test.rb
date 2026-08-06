require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email is normalized to lowercase" do
    user = User.new(
      name: "Test User",
      email: "TeSt@Example.COM",
      address: "123 Space Lane",
      password: "password",
      password_confirmation: "password"
    )

    user.validate

    assert_equal "test@example.com", user.email
  end

  test "email uniqueness is case insensitive" do
    User.create!(name: "Existing", email: "existing@example.com", address: "123 Space Lane", password: "password", password_confirmation: "password")
    duplicate = User.new(name: "Other", email: "EXISTING@example.com", address: "123 Space Lane", password: "password", password_confirmation: "password")

    refute duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end
end
