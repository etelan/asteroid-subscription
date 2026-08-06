class OnboardingController < ApplicationController
  STEPS = %w[account plan confirm].freeze

  before_action :load_draft
  before_action :load_plans, only: %i[show update]

  def show
    @step = normalize_step(params[:step])
  end

  def update
    @step = normalize_step(params[:step])

    @draft.merge!(submitted_attributes)

    if @step == "account" && account_valid?
      redirect_to onboarding_path(step: "plan")
    elsif @step == "plan" && plan_valid?
      redirect_to onboarding_path(step: "confirm")
    elsif @step == "confirm" && confirmation_valid?
      complete_onboarding
    else
      @error = "Please complete the required fields."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def load_draft
    session[:onboarding] ||= {}
    @draft = session[:onboarding]
  end

  def normalize_step(step)
    STEPS.include?(step.to_s) ? step.to_s : "account"
  end

  def submitted_attributes
    params.permit(:name, :email, :address, :plan_id).to_h
  end

  def account_valid?
    @draft["name"].present? && @draft["email"].present?
  end

  def plan_valid?
    @plans.exists?(id: @draft["plan_id"])
  end

  def confirmation_valid?
    @draft["name"].present? &&
      @draft["email"].present? &&
      plan_valid?
  end

  def load_plans
    @plans = Plan.order(:min_diameter)
  end

  def complete_onboarding
    session.delete(:onboarding)

    redirect_to root_path,
                notice: "Your subscription setup is ready."
  end
end
