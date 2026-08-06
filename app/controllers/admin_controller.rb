class AdminController < ApplicationController
  before_action :require_admin!, only: %i[dashboard logout asteroid plan]

  def login
  end

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

  def dashboard
    @users = User.includes(:plan, :upcoming_asteroid).order(created_at: :desc)
    @plans = Plan.order(:min_diameter)
  end

  def asteroid
    @asteroid = Asteroid.find(params[:id])
  end

  def plan
    @plan = Plan.find(params[:id])
    @asteroid_count = Asteroid.where(diameter: @plan.min_diameter..@plan.max_diameter).count
  end

  def logout
    session.delete(:admin_user_id)
    redirect_to admin_login_path, notice: "Signed out"
  end

  private

  def require_admin!
    return if current_admin

    redirect_to admin_login_path, alert: "Admin login required"
  end

  def current_admin
    @current_admin ||= User.find_by(id: session[:admin_user_id], is_admin: true)
  end
  helper_method :current_admin
end
