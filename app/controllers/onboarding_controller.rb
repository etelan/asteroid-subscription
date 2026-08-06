class OnboardingController < ApplicationController
  STEPS = %w[account plan confirm].freeze

  before_action :set_step
  before_action :load_draft
  before_action :load_plans, only: %i[show update]
  before_action :load_selected_plan, only: %i[show update]
  before_action :load_selected_asteroid, only: %i[show update]

  def show
  end

  def update
    @draft.merge!(submitted_attributes)

    if @step == "account"
      if params[:password] != params[:password_confirmation]
        @error = "Passwords must match."
        @draft["name"] = params[:name]
        @draft["email"] = params[:email]
        @draft["address"] = params[:address]
        @error = "Passwords do not match."
        render :show, status: :unprocessable_entity
        return
      end
    end

    if @step == "plan"
      unless @draft["plan_id"].present?
        @error = "Please select a plan first."
        render :show, status: :unprocessable_entity
        return
      end

      @draft.delete("asteroid_id")
      session[:onboarding] = @draft
      redirect_to onboarding_path(step: "confirm")
      return
    end

    if @step == "confirm"
      unless @selected_asteroid
        @error = "No asteroid available for this plan."
        render :show, status: :unprocessable_entity
        return
      end

      user = User.new(
        name: @draft["name"],
        email: @draft["email"],
        address: @draft["address"],
        password: @draft["password"],
        password_confirmation: @draft["password_confirmation"],
        plan: @selected_plan,
        plan_start_date: Date.current,
        upcoming_asteroid: @selected_asteroid
      )

      if user.save
        @selected_asteroid.update(user: user)
        session.delete(:onboarding)
        redirect_to root_path, notice: "Subscription ready."
      else
        @error = user.errors.full_messages.to_sentence
        render :show, status: :unprocessable_entity
      end

      return
    end

    redirect_to onboarding_path(step: next_step(@step))
  end

  private

  def set_step
    @step = normalize_step(params[:step])
  end

  def load_draft
    session[:onboarding] ||= {}
    @draft = session[:onboarding]
  end

  def normalize_step(step)
    STEPS.include?(step.to_s) ? step.to_s : "account"
  end

  def submitted_attributes
    params.permit(:name,
                  :email,
                  :address,
                  :plan_id,
                  :password,
                  :password_confirmation,
                  :step).to_h
  end

  def load_plans
    @plans = Plan.order(:min_diameter)
  end

  def load_selected_plan
    @selected_plan = Plan.find_by(id: @draft["plan_id"])
  end

  def load_selected_asteroid
    return unless @selected_plan
    return unless @step == "confirm"

    @draft["asteroid_id"] ||= pick_random_asteroid_id(@selected_plan)
    session[:onboarding] = @draft
    @selected_asteroid = Asteroid.find_by(id: @draft["asteroid_id"])
    puts "Selected asteroid: #{@selected_asteroid&.inspect || 'none'}"
  end

  def pick_random_asteroid_id(plan)
    Asteroid
      .where(diameter: plan.min_diameter..plan.max_diameter)
      .order(Arel.sql("RANDOM()"))
      .limit(1)
      .pick(:id)
  end

  def next_step(step)
    case step
    when "account" then "plan"
    when "plan" then "confirm"
    else "confirm"
    end
  end
end
