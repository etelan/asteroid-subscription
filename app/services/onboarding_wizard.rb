class OnboardingWizard
  # Ordered list of steps in the onboarding flow.
  STEPS = %w[account plan confirm].freeze

  attr_reader :session, :step, :plans, :draft, :selected_plan, :selected_asteroid, :error

  # Initializes the wizard state from the session and incoming params.
  #
  # session - Rails session object used to persist onboarding progress.
  # params  - Request parameters for the current step.
  def initialize(session:, params: {})
    @session = session
    @draft = load_draft
    @step = normalize_step(params[:step])
    @params = params

    # Plans are displayed on the plan selection step.
    @plans = Plan.order(:min_diameter)

    # Restore the user's selected plan from the draft data.
    @selected_plan = Plan.find_by(id: draft["plan_id"])

    # Memoized later when previewing the assigned asteroid.
    @selected_asteroid = nil
  end

  # Merges submitted data into the draft and validates
  # the current step.
  #
  # Returns true when the step is valid, otherwise false.
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

  # Returns the next step in the onboarding flow.
  def next_step
    case step
    when "account" then "plan"
    when "plan" then "confirm"
    else "confirm"
    end
  end

  # Assigns a random asteroid matching the selected plan's
  # diameter range. The assignment only happens once.
  def choose_asteroid!
    return unless selected_plan
    return if draft["asteroid_id"].present?

    draft["asteroid_id"] = Asteroid
      .in_diameter_range(selected_plan.min_diameter, selected_plan.max_diameter)
      .order(Arel.sql("RANDOM()"))
      .pick(:id)

    @selected_asteroid = nil
    persist_draft
  end

  # Returns the assigned asteroid for preview purposes.
  # Result is memoized for repeated access.
  def asteroid_for_preview
    @selected_asteroid ||= Asteroid.find_by(id: draft["asteroid_id"])
  end

  # Returns the currently selected plan.
  def plan_summary
    selected_plan
  end

  private

  attr_reader :params

  # Loads the onboarding draft from the session,
  # creating an empty draft if none exists.
  def load_draft
    session[:onboarding] ||= {}
    session[:onboarding]
  end

  # Persists the current draft back into the session.
  def persist_draft
    session[:onboarding] = draft
  end

  # Ensures only valid onboarding steps can be used.
  # Defaults to the first step if an invalid value is provided.
  def normalize_step(step)
    STEPS.include?(step.to_s) ? step.to_s : "account"
  end

  # Extracts and permits onboarding parameters from the request.
  def submitted_attributes
    params.permit(
      :name,
      :email,
      :address,
      :plan_id,
      :password,
      :password_confirmation,
      :step
    ).to_h
  end

  # Merges newly submitted attributes into the draft.
  #
  # If the selected plan changes, discard any previously assigned
  # asteroid and immediately assign a new one for the new plan.
  def merge_draft(new_attributes)
    previous_plan_id = draft["plan_id"]

    draft.merge!(new_attributes)

    if draft["plan_id"] != previous_plan_id
      draft.delete("asteroid_id")
      @selected_plan = Plan.find_by(id: draft["plan_id"])
      @selected_asteroid = nil

      choose_asteroid!
    end

    persist_draft
  end

  # Validates account creation fields.
  def validate_account_step
    if params[:password] != params[:password_confirmation]
      @error = "Passwords must match."
      return false
    end

    true
  end

  # Ensures a plan has been selected before continuing.
  def validate_plan_step
    return true if draft["plan_id"].present?

    @error = "Please select a plan first."
    false
  end

  # Ensures an asteroid has been assigned before the
  # user can complete onboarding.
  def validate_confirm_step
    unless asteroid_for_preview
      @error = "No asteroid available for this plan."
      return false
    end

    true
  end
end
