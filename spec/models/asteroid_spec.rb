require "rails_helper"

RSpec.describe Asteroid do
  describe "validations" do
    it "requires a spkid" do
      asteroid = build(:asteroid, spkid: nil)

      expect(asteroid).not_to be_valid
      expect(asteroid.errors[:spkid]).to include("can't be blank")
    end
  end
end
