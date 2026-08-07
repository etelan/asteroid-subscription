class AddOnboardingStepToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :onboarding_step, :string
  end
end
