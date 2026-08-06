require "net/http"
require "uri"
require "json"
require_relative "asteroid"

class AsteroidFetcher
  # Updated to NeoWs endpoint [3]
  ASTEROID_LOOKUP_URL = "https://www.neowsapp.com/rest/v1/neo/browse?page=0&size=300&api_key=SaVp1tZ6A7uXiVUUF8GGDiDXQzyD0hozX0Ne32Wp"

  def self.random_diameter(min_km:, max_km:, api_key: ENV["JPL_API_KEY"])
    # Fetch 1000 from NeoWs list [3]
    rows = query_candidates(min_km: min_km, max_km: max_km, api_key: api_key)
    raise "No matching asteroids found" if rows.empty?

    chosen = rows.sample
    puts "Selected asteroid: #{chosen['name']} with diameter #{chosen.dig('estimated_diameter', 'kilometers', 'estimated_diameter_max')} km"
    # Fetch full record (if applicable) or use chosen data [3]
    # record = fetch_full_record(chosen["name"], api_key: api_key)

    Asteroid.new(candidate: chosen, full_record: record)
  end

  def self.query_candidates(min_km:, max_km:, api_key:)
    # NeoWs uses size/page for pagination [3]
    json = get_json(NEOWS_BROWSE_URL)

    # Update logic to traverse NeoWs nested structure [3]
    data = json["near_earth_objects"] || []

    puts "Fetched #{data.size} candidates from NeoWs"

    data.select do |obj|
      # Extract diameter from nested keys [1][3]
      diam = obj.dig("estimated_diameter", "kilometers", "estimated_diameter_max").to_f
      puts "Checking asteroid #{obj['name']} with diameter #{diam} km. (Between #{min_km} and #{max_km})"
      diam >= min_km.to_f && diam <= max_km.to_f
    end
  end

  # def self.fetch_full_record(identifier, api_key:)
  #   # This method remains for potential supplemental data
  #   # but logic depends on specific API requirements [4]
  #   params = {
  #     sstr: identifier,
  #     phys_par: 1,
  #     ca_data: 1,
  #     discovery: 1,
  #     vi_data: 1,
  #     full_prec: 1,
  #     api_key: api_key
  #   }

  #   get_json(SBDB_URL) # Note: Keep SBDB logic if dual-source, or replace with NeoWs specific call
  # end

  def self.get_json(base_url)
    uri = URI(base_url)
    response = Net::HTTP.get_response(uri)
    raise "HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  end
end
