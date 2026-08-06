class OnboardingController < ApplicationController
  # Displays the current onboarding step.
  # Any previously entered data is restored from the session.
  def show
    build_wizard
    sync_view_state
  end

  # Handles form submissions for every onboarding step.
  #
  # Valid steps redirect to the next page until the final
  # confirmation step, where the User record is created.
  def update
    build_wizard

    puts @wizard.inspect

    if @wizard.submit
      if @wizard.step == "confirm"
        # Build the user from the accumulated draft data.
        user = User.new(
          name: @wizard.draft["name"],
          email: @wizard.draft["email"],
          address: @wizard.draft["address"],
          password: @wizard.draft["password"],
          password_confirmation: @wizard.draft["password_confirmation"],
          plan: @wizard.plan_summary,
          plan_start_date: Date.current,
          upcoming_asteroid: @wizard.asteroid_for_preview
        )

        if user.save
          # Link the assigned asteroid to the newly created user.
          @wizard.asteroid_for_preview.update(user: user)

          # Clear the onboarding session once registration is complete.
          session.delete(:onboarding)

          # Prepare the completion page.
          @submission_complete = true
          @saved_asteroid = @wizard.asteroid_for_preview
          sync_view_state
          @step = "complete"

          render :show
          return
        end

        # Surface any validation errors from the User model.
        @wizard.instance_variable_set(:@error, user.errors.full_messages.to_sentence)
      else
        # Move to the next onboarding step.
        redirect_to onboarding_path(step: @wizard.next_step)
        return
      end
    end

    # Re-render the current step with any validation errors.
    sync_view_state
    @error = @wizard.error
    render :show, status: :unprocessable_entity
  end

  private

  # Creates a wizard instance for the current request.
  def build_wizard
    @wizard = OnboardingWizard.new(session: session, params: params)
  end

  # Copies the wizard state into instance variables
  # used by the onboarding view.
  def sync_view_state
    @step = @wizard.step
    @draft = @wizard.draft
    @plans = @wizard.plans

    # Only load the asteroid preview on the confirmation step.
    @selected_asteroid = @wizard.asteroid_for_preview if @wizard.step == "confirm"
  end
end
