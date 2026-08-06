namespace :asteroids do
  desc "Ingest asteroid records from JPL SBDB using plan diameter ranges"
  task ingest: :environment do
    require "net/http"
    require "json"
    require "uri"

    field_list = %w[
      spkid
      full_name
      diameter
      diameter_sigma
      first_obs
      last_obs
      kind
      moid_ld
    ].join(",")

    max_per_plan = 300

    Plan.order(:min_diameter).each do |plan|
      query = { "AND" => [ "diameter|RG|#{plan.min_diameter}|#{plan.max_diameter}" ] }.to_json
      uri = URI("https://ssd-api.jpl.nasa.gov/sbdb_query.api")
      uri.query = URI.encode_www_form(
        fields: field_list,
        "sb-kind": "a",
        "sb-cdata": query,
        limit: max_per_plan
      )

      puts "Fetching asteroids for #{plan.name} (#{plan.min_diameter}-#{plan.max_diameter} km)"

      response = Net::HTTP.get_response(uri)
      unless response.is_a?(Net::HTTPSuccess)
        warn "Failed to fetch #{plan.name}: #{response.code} #{response.message}"
        next
      end

      body = JSON.parse(response.body)
      fields = body["fields"] || []
      rows = (body["data"] || []).first(max_per_plan)

      puts "  fetched #{rows.size} rows"

      first_saved = nil
      saved_count = 0

      rows.each do |row|
        attrs = Hash[fields.zip(row)]

        asteroid = Asteroid.find_or_initialize_by(spkid: attrs["spkid"])
        asteroid.assign_attributes(
          full_name: attrs["full_name"],
          diameter: attrs["diameter"].to_f,
          diameter_sigma: attrs["diameter_sigma"].to_f,
          first_obs: attrs["first_obs"],
          last_obs: attrs["last_obs"],
          kind: attrs["kind"],
          moid_ld: attrs["moid_ld"].to_f
        )

        if asteroid.save
          saved_count += 1
          first_saved ||= asteroid
        else
          warn "  skipped #{attrs['spkid']}: #{asteroid.errors.full_messages.join(', ')}"
        end
      rescue StandardError => e
        warn "  skipped #{attrs['spkid']}: #{e.message}"
      end

      puts "  loaded #{saved_count} rows"
      if first_saved
        puts "  first successful asteroid: #{first_saved.spkid} (#{first_saved.full_name})"
      else
        puts "  no successful asteroid saved for this band"
      end
    end
  end
end
