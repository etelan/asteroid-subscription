class OnboardingWizard
  STEPS = %w[account plan confirm].freeze

  attr_reader :step, :plans, :error, :saved_asteroid

  # Initialise with
  # user's session,
  # users's http params,
  # user's temp onboarding data,
  # step they are on,
  # what plan they picked,
  # and if they have finished or not
  def initialize(session:, params: {})
    @session = session
    @params = params
    @draft = load_draft
    @step = normalize_step(params[:step])
    @plans = Plan.order(:min_diameter)
    @finished = false
  end

  # The next button.
  # Temp Save Data -> Validate Data -> Next step
  def submit
    merge_draft(submitted_attributes)

    case step
    when "account" then validate_account_step
    when "plan"    then validate_plan_step
    when "confirm" then complete_onboarding
    end
  end

  def finished?
    @finished
  end

  def next_step
    STEPS.fetch(STEPS.index(step) + 1, STEPS.last)
  end

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

  def load_draft
    session[:onboarding] ||= {}
  end

  def persist_draft
    session[:onboarding] = draft
  end

  def normalize_step(step)
    STEPS.include?(step.to_s) ? step.to_s : STEPS.first
  end

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

  def merge_draft(attributes)
    previous_plan_id = plan_id

    draft.merge!(attributes)

    if plan_id != previous_plan_id
      draft.delete("asteroid_id")
      @selected_plan = nil
      @selected_asteroid = nil
      choose_asteroid!
    end

    persist_draft
  end

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

  # Backend logic for validating account page.
  # If I Had More Time: Email validation. Address dropdown and validation.
  def validate_account_step
    # Password = Password Conf
    unless draft["password"] == draft["password_confirmation"]
      @error = "Passwords must match."
      return false
    end

    # Email has to be free
    if User.exists?(email: draft["email"])
      @error = "An account with this email already exists."
      return false
    end

    true
  end

  # Backend logic for plan settings validation
  # Gotta pick a plan!
  def validate_plan_step
    return true if selected_plan.present?

    @error = "Please select a plan first."
    false
  end

  # This will check if an asteroid is available for you before you confirm.
  # If I Had More Time: I'd cross out plans that have no asteroids left.
  def validate_confirm_step
    return true if selected_asteroid.present?

    @error = "No asteroid available for this plan."
    false
  end

  # Saving the User to db.
  def complete_onboarding
    return false unless validate_confirm_step

    # Make the model.
    user = User.new(
      name: draft["name"],
      email: draft["email"],
      address: draft["address"],
      password: draft["password"],
      password_confirmation: draft["password_confirmation"],
      plan: selected_plan,
      plan_start_date: Date.current,
      upcoming_asteroid: selected_asteroid
    )

    # Save it to DB. And, make the asteroid owned.
    # Password is saved as password_digest in DB. Hashed.
    ActiveRecord::Base.transaction do
      user.save!
      selected_asteroid.update!(user: user)
    end

    # Set our saved asteroid so the confirm view can show it
    @saved_asteroid = selected_asteroid
    @finished = true
    session.delete(:onboarding)

    true
  rescue ActiveRecord::RecordInvalid => error
    @error = error.record.errors.full_messages.to_sentence
    false
  end
end
