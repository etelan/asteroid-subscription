require "rails_helper"

RSpec.describe "Admin", type: :request do
  it "redirects unauthenticated users away from the dashboard" do
    get admin_dashboard_path

    expect(response).to redirect_to(admin_login_path)
  end

  it "logs in an admin user" do
    create(
      :user,
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      is_admin: true
    )

    post admin_authenticate_path, params: {
      email: "admin@example.com",
      password: "password123"
    }

    expect(response).to redirect_to(admin_dashboard_path)
  end

  it "shows each user's onboarding step on the dashboard" do
    admin = create(
      :user,
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      is_admin: true
    )
    create(
      :user,
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      onboarding_step: "plan"
    )

    post admin_authenticate_path, params: {
      email: admin.email,
      password: "password123"
    }
    get admin_dashboard_path

    expect(response.body).to include("Onboarding step")
    expect(response.body).to include("plan")
  end

  it "stays on the login page when the password is wrong" do
    create(
      :user,
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123",
      is_admin: true
    )

    post admin_authenticate_path, params: {
      email: "admin@example.com",
      password: "wrong-password"
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Email or password invalid")
  end

  it "stays on the login page for a non-admin user" do
    create(
      :user,
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      is_admin: false
    )

    post admin_authenticate_path, params: {
      email: "user@example.com",
      password: "password123"
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Email or password invalid")
  end
end
