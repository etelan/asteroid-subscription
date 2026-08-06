class OnboardingController < ApplicationController
  def show
    build_wizard
    sync_view_state
  end

  def update
    build_wizard

    if @wizard.submit
      if @wizard.step == "confirm"
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
          @wizard.asteroid_for_preview.update(user: user)
          session.delete(:onboarding)
          redirect_to root_path, notice: "Subscription ready."
          return
        end

        @wizard.instance_variable_set(:@error, user.errors.full_messages.to_sentence)
      else
        redirect_to onboarding_path(step: @wizard.next_step)
        return
      end
    end

    sync_view_state
    @error = @wizard.error
    render :show, status: :unprocessable_entity
  end

  private

  def build_wizard
    @wizard = OnboardingWizard.new(session: session, params: params)
  end

  def sync_view_state
    @step = @wizard.step
    @draft = @wizard.draft
    @plans = @wizard.plans
    @selected_asteroid = @wizard.asteroid_for_preview if @wizard.step == "confirm"
  end
end
