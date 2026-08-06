class OnboardingWizard
  STEPS = %w[account plan confirm].freeze

  attr_reader :session, :step, :plans, :draft, :selected_plan, :selected_asteroid, :error

  def initialize(session:, params: {})
    @session = session
    @draft = load_draft
    @step = normalize_step(params[:step])
    @params = params
    @plans = Plan.ordered_by_min_diameter
    @selected_plan = Plan.find_by(id: draft["plan_id"])
    @selected_asteroid = nil
  end

  def submit
    merge_draft(submitted_attributes)

    case step
    when "account"
      validate_account_step
    when "plan"
      validate_plan_step
    when "confirm"
      validate_confirm_step
    else
      true
    end
  end

  def next_step
    case step
    when "account" then "plan"
    when "plan" then "confirm"
    else "confirm"
    end
  end

  def choose_asteroid!
    return unless selected_plan
    return if draft["asteroid_id"].present?

    draft["asteroid_id"] = Asteroid.in_diameter_range(selected_plan.min_diameter, selected_plan.max_diameter)
                                          .order(Arel.sql("RANDOM()"))
                                          .pick(:id)
    persist_draft
  end

  def asteroid_for_preview
    @selected_asteroid ||= Asteroid.find_by(id: draft["asteroid_id"])
  end

  def plan_summary
    selected_plan
  end

  private

  attr_reader :params

  def load_draft
    session[:onboarding] ||= {}
    session[:onboarding]
  end

  def persist_draft
    session[:onboarding] = draft
  end

  def normalize_step(step)
    STEPS.include?(step.to_s) ? step.to_s : "account"
  end

  def submitted_attributes
    params.permit(:name, :email, :address, :plan_id, :password, :password_confirmation, :step).to_h
  end

  def merge_draft(new_attributes)
    draft.merge!(new_attributes)
    persist_draft
  end

  def validate_account_step
    if params[:password] != params[:password_confirmation]
      @error = "Passwords must match."
      return false
    end

    true
  end

  def validate_plan_step
    return true if draft["plan_id"].present?

    @error = "Please select a plan first."
    false
  end

  def validate_confirm_step
    choose_asteroid!

    unless asteroid_for_preview
      @error = "No asteroid available for this plan."
      return false
    end

    true
  end
end
