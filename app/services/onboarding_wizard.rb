class OnboardingWizard
  STEPS = %w[account plan confirm].freeze

  attr_reader :step, :plans, :error, :saved_asteroid

  # Initialise with
  # user's session,
  # user's http params,
  # user's temp onboarding data,
  # step they are on,
  # and the available plans.
  def initialize(session:, params: {})
    @session = session
    @params = params
    @draft = load_draft
    @step = normalize_step(params[:step])
    @plans = Plan.order(:min_diameter)
    @finished = false
  end

  # The next button.
  # Save the draft, validate the step, then move us forward.
  def submit
    merge_draft(submitted_attributes)

    # Each step does one thing.
    case step
    when "account" then submit_account_step
    when "plan"    then submit_plan_step
    when "confirm" then submit_confirm_step
    end
  end

  # Used by the progress bar.
  def finished?
    @finished
  end

  # The next step in the wizard.
  def next_step
    STEPS.fetch(STEPS.index(step) + 1, STEPS.last)
  end

  # These just read back the saved draft data.
  def name
    draft["name"]
  end

  def email
    draft["email"]
  end

  def address
    draft["address"]
  end

  def plan_id
    draft["plan_id"]
  end

  def selected_plan
    @selected_plan ||= Plan.find_by(id: plan_id)
  end

  def selected_asteroid
    @selected_asteroid ||= Asteroid.find_by(id: draft["asteroid_id"])
  end

  private

  attr_reader :session, :params, :draft

  # Keep the temp data in session so the form can do page changes.
  def load_draft
    session[:onboarding] ||= {}
  end

  # Write the temp data back to session after each change.
  def persist_draft
    session[:onboarding] = draft
  end

  # The user we created after the account step.
  def onboarding_user
    @onboarding_user ||= User.find_by(id: session[:onboarding_user_id])
  end

  # Update the current onboarding user, if we have one.
  def update_onboarding_user!(attributes)
    user = onboarding_user
    return false unless user

    user.update!(attributes)
  end

  # If the step is invalid, start at the beginning.
  def normalize_step(step)
    STEPS.include?(step.to_s) ? step.to_s : STEPS.first
  end

  # Only allow the form fields we expect.
  def submitted_attributes
    params.permit(
      :name,
      :email,
      :address,
      :plan_id,
      :password,
      :password_confirmation
    ).to_h
  end

  # Merge the latest form values into the temp data.
  def merge_draft(attributes)
    previous_plan_id = plan_id

    draft.merge!(attributes)

    # If the plan changed, clear the old asteroid and pick a new one.
    if plan_id != previous_plan_id
      draft.delete("asteroid_id")
      @selected_plan = nil
      @selected_asteroid = nil
      choose_asteroid!
    end

    persist_draft
  end

  # Pick one asteroid that fits the selected plan.
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

  # Backend logic for validating the account page.
  # If I Had More Time: email validation. Address dropdown and validation.
  def validate_account_step
    # Password and confirmation have to match.
    unless draft["password"] == draft["password_confirmation"]
      @error = "Passwords must match."
      return false
    end

    # Email has to be free.
    if User.exists?(email: draft["email"])
      @error = "An account with this email already exists."
      return false
    end

    true
  end

  # Create the user as soon as account details pass validation.
  def submit_account_step
    return false unless validate_account_step

    # Create the user here so later steps can update the same record.
    user = User.create(
      name: draft["name"],
      email: draft["email"],
      address: draft["address"],
      onboarding_step: "account",
      password: draft["password"],
      password_confirmation: draft["password_confirmation"]
    )

    if user.persisted?
      session[:onboarding_user_id] = user.id
      true
    else
      @error = user.errors.full_messages.to_sentence
      false
    end
  end

  # Backend logic for the plan step.
  # Gotta pick a plan!
  def validate_plan_step
    return true if selected_plan.present?

    @error = "Please select a plan first."
    false
  end

  # Update the user record so we know they reached the plan step.
  def submit_plan_step
    return false unless validate_plan_step
    # This is the same user from the account step.
    return false unless update_onboarding_user!(onboarding_step: "plan")

    true
  end

  # This checks if an asteroid is available before we confirm.
  # If I Had More Time: I'd cross out plans that have no asteroids left.
  def validate_confirm_step
    return true if selected_asteroid.present?

    @error = "No asteroid available for this plan."
    false
  end

  # Save the final plan details and mark the user as finished.
  def submit_confirm_step
    return false unless validate_confirm_step

    # Final update goes in one transaction with the asteroid claim.
    user = onboarding_user
    return false unless user

    ActiveRecord::Base.transaction do
      # Store the last onboarding state on the user.
      user.update!(
        onboarding_step: "confirm",
        plan: selected_plan,
        plan_start_date: Date.current,
        upcoming_asteroid: selected_asteroid
      )
      # Claim the asteroid for this user.
      selected_asteroid.update!(user: user)
    end

    # Set our saved asteroid so the confirm view can show it
    @saved_asteroid = selected_asteroid
    @finished = true
    session.delete(:onboarding)
    session.delete(:onboarding_user_id)

    true
  rescue ActiveRecord::RecordInvalid => error
    @error = error.record.errors.full_messages.to_sentence
    false
  end
end
