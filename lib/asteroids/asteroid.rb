class Asteroid
  attr_reader :candidate, :full_record

  def initialize(candidate:, full_record:)
    @candidate = candidate
    @full_record = full_record
  end

  def id
    candidate["name"] || candidate["designation"]
  end

  def name
    candidate["name"]
  end

  def diameter_km
    # Check NeoWs data first, then fallback to SBDB record [3]
    candidate.dig("estimated_diameter", "kilometers", "estimated_diameter_max")&.to_f ||
    full_record.dig("phys_par", "diameter")&.to_f
  end

  def url
    # New field from NeoWs [3]
    candidate["nasa_jpl_url"]
  end

  def kind
    candidate["kind"] || full_record.dig("object", "kind")
  end
end
