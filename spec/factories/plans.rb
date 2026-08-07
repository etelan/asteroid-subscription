FactoryBot.define do
  factory :plan do
    name { "Starter" }
    price { 9.99 }
    min_diameter { 0.5 }
    max_diameter { 1.0 }
    description { "A starter plan" }
  end
end
