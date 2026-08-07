class AdminController < ApplicationController
  before_action :require_admin!, only: %i[dashboard logout]
  layout "admin"

  # (GET) Allows us to see the login view
  def login
  end

  # The actual login logic
  # (POST) We are creating a session
  def authenticate
    email = params[:email].to_s.strip.downcase
    password = params[:password]

    user = User.find_by("lower(email) = ?", email)

    if user&.authenticate(password) && user.is_admin?
      session[:admin_user_id] = user.id
      redirect_to admin_dashboard_path
    else
      flash.now[:alert] = "Email or password invalid"
      render :login, status: :unprocessable_entity
    end
  end

  # (GET) Serves our dashboard view
  # If I Had More Time: I'd love to add how many users signed up per plan
  def dashboard
    @users = User.includes(:plan, :upcoming_asteroid).order(created_at: :desc)
    @plans = Plan.order(:min_diameter)
  end

  # (DELETE) We are deleting the users session
  def logout
    session.delete(:admin_user_id)
    redirect_to root_path, notice: "Signed out"
  end

  private

  # Simple method to gatekeep pages and methods behind admin auth
  def require_admin!
    return if current_admin

    redirect_to admin_login_path, alert: "Admin login required"
  end

  # If I Had More Time: Index not just on Email and Password but also on is_admin
  def current_admin
    @current_admin ||= User.find_by(id: session[:admin_user_id], is_admin: true)
  end
  helper_method :current_admin
end
