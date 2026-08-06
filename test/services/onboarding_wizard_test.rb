require "test_helper"

class OnboardingWizardTest < ActiveSupport::TestCase
  test "wizard prepares plan list and selected plan" do
    plan = Plan.create!(name: "Test Plan", price: 10.0, min_diameter: 0.1, max_diameter: 1.0)
    wizard = OnboardingWizard.new(session: {}, params: ActionController::Parameters.new(step: "plan"))

    assert_equal [plan], wizard.plans
    assert_equal "plan", wizard.step
  end

  test "wizard validates account step passwords must match" do
    wizard = OnboardingWizard.new(session: {}, params: ActionController::Parameters.new(step: "account", password: "password", password_confirmation: "wrong"))

    refute wizard.submit
    assert_equal "Passwords must match.", wizard.error
  end

  test "wizard validates plan selection before moving on" do
    wizard = OnboardingWizard.new(session: {}, params: ActionController::Parameters.new(step: "plan"))

    refute wizard.submit
    assert_equal "Please select a plan first.", wizard.error
  end
end
