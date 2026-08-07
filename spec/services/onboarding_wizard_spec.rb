require "rails_helper"

RSpec.describe OnboardingWizard do
  let(:session) { {} }

  def build_wizard(step, **params)
    described_class.new(
      session: session,
      params: ActionController::Parameters.new(
        { step: step }.merge(params)
      )
    )
  end

  describe "#submit" do
    it "accepts valid account details" do
      result = build_wizard(
        "account",
        name: "Alex",
        email: "alex@example.com",
        address: "123 Street",
        password: "password123",
        password_confirmation: "password123"
      ).submit

      expect(result).to be true
    end

    it "rejects mismatching passwords" do
      onboarding = build_wizard(
        "account",
        password: "password123",
        password_confirmation: "different"
      )

      expect(onboarding.submit).to be false
      expect(onboarding.error).to eq("Passwords must match.")
    end

    it "rejects an existing email" do
      create(:user, email: "alex@example.com")

      onboarding = build_wizard(
        "account",
        email: "alex@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(onboarding.submit).to be false
    end

    it "selects a plan and asteroid" do
      plan = create(:plan, min_diameter: 0.5, max_diameter: 1)
      asteroid = create(:asteroid, diameter: 0.75)

      onboarding = build_wizard("plan", plan_id: plan.id)

      expect(onboarding.submit).to be true
      expect(onboarding.selected_plan).to eq(plan)
      expect(onboarding.selected_asteroid).to eq(asteroid)
    end
  end
end
