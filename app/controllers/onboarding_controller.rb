class OnboardingController < ApplicationController
  # (GET) This is the first page load of the onboarding wizard
  def show
    build_wizard
  end

  # (PATCH) Because we are updating the users session details.
  # Subsequent Turbo Pages for onboarding.
  def update
    build_wizard

    unless @wizard.submit
      render :show, status: :unprocessable_entity
      return
    end

    # If it's at the end, it will render show view with _success partial
    if @wizard.finished?
      render :show
    else
      # Otherwise we'll move onto the next screen
      redirect_to onboarding_path(step: @wizard.next_step)
    end
  end

  private

  # If I had more time: I'd make one onboarding wizard persist throughout a users signup.
  def build_wizard
    @wizard = OnboardingWizard.new(session: session, params: params)
  end
end
