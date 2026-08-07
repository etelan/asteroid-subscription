require "rails_helper"

RSpec.describe Plan do
  describe "validations" do
    it "requires a name" do
      plan = build(:plan, name: nil)

      expect(plan).not_to be_valid
      expect(plan.errors[:name]).to include("can't be blank")
    end

    it "requires max diameter to be greater than or equal to min diameter" do
      plan = build(:plan, min_diameter: 2, max_diameter: 1)

      expect(plan).not_to be_valid
      expect(plan.errors[:max_diameter]).to include("must be greater than or equal to min diameter")
    end
  end
end
