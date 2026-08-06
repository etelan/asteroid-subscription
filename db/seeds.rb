plans = [
  {
    name: "Car Size",
    description: "Less than 0.1km in diameter. Will explode in atmosphere.",
    min_diameter: 0.0,
    max_diameter: 0.1,
    price: 19.0
  },
  {
    name: "Eiffel Tower Size",
    description: "0.1km - 1km in diameter. May destroy your city.",
    min_diameter: 0.1,
    max_diameter: 1.0,
    price: 19.0
  },
  {
    name: "London Size",
    description: "1km - 100km in diameter. May destroy the earth's ecosystem.",
    min_diameter: 1.0,
    max_diameter: 100.0,
    price: 39.0
  },
  {
    name: "United Kingdom Size",
    description: "100km - 1000km in diameter. May evaporate all water on Earth.",
    min_diameter: 100.0,
    max_diameter: 1000.0,
    price: 39.0
  }
]

plans.each do |attrs|
  Plan.find_or_create_by!(name: attrs[:name]) do |plan|
    plan.description = attrs[:description]
    plan.min_diameter = attrs[:min_diameter]
    plan.max_diameter = attrs[:max_diameter]
    plan.price = attrs[:price]
  end
end
