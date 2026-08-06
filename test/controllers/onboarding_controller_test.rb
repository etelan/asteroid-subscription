require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "renders a saved-subscription success state after the final step" do
    plan = Plan.create!(name: "Orbit", price: 12, min_diameter: 1, max_diameter: 10)
    asteroid = Asteroid.create!(spkid: "AST-001", diameter: 5, moid_ld: 3, full_name: "Test Asteroid")

    get onboarding_path(step: "account")
    assert_response :success

    patch onboarding_path(step: "account"), params: {
      step: "account",
      name: "Alex Morgan",
      email: "alex@example.com",
      address: "123 Example Street",
      password: "password123",
      password_confirmation: "password123"
    }
    assert_redirected_to onboarding_path(step: "plan")

    follow_redirect!
    assert_response :success

    patch onboarding_path(step: "plan"), params: {
      step: "plan",
      plan_id: plan.id
    }
    assert_redirected_to onboarding_path(step: "confirm")

    follow_redirect!
    assert_response :success

    patch onboarding_path(step: "confirm"), params: {
      step: "confirm"
    }

    assert_response :success
    assert_includes response.body, "You may pay on arrival"
    assert_includes response.body, "Your request has been saved."
    assert_includes response.body, "View asteroid"
    assert_includes response.body, "Return home"
    assert_equal asteroid.id, asteroid.reload.id
  end
end
