FactoryBot.define do
  factory :asteroid do
    sequence(:spkid) { |n| "SPKID-#{n}" }
    diameter { 0.75 }
    moid_ld { 1.2 }
    full_name { "Test Asteroid" }
    kind { "Apollo" }
  end
end
