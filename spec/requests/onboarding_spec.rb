require "rails_helper"

RSpec.describe "Onboarding", type: :request do
  it "shows the initial account onboarding page" do
    get onboarding_path(step: "account")

    expect(response).to have_http_status(:ok)
  end

  it "moves from account to plan step" do
    patch onboarding_path(step: "account"), params: valid_account_params

    expect(response).to redirect_to(onboarding_path(step: "plan"))
  end

  it "shows validation errors in account step" do
    patch onboarding_path(step: "account"), params: {
      password: "password123",
      password_confirmation: "different"
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Passwords must match.")
  end

  it "shows validation errors in plan step" do
    patch onboarding_path(step: "plan"), params: {}

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Please select a plan first.")
  end

  def valid_account_params
    {
      name: "Alex",
      email: "alex@example.com",
      address: "123 Street",
      password: "password123",
      password_confirmation: "password123"
    }
  end
end
