class Asteroid < ApplicationRecord
  LUNAR_DISTANCE_KM = 384_400

  # A user claims it at the end of the signup process
  belongs_to :user, optional: true

  # If I Had More Time: I'd migrate the database to make it so asteroid:user is 1:1.
  has_one :upcoming_users,
           class_name: "User",
           foreign_key: :upcoming_asteroid_id,
           inverse_of: :upcoming_asteroid

  # TLDR: Do we have an ID?
  # Do we have a diameter that isn't negative?
  # Do we have a moid_ld that isn't negative?
  validates :spkid, presence: true, uniqueness: true
  validates :diameter,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true
  validates :moid_ld,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # Allows us to scope back the asteroids per plan
  scope :in_diameter_range, ->(min, max) { where(diameter: min..max) }

  # Translate it into kilometers as earthlings do not think in Lunar Distances.
  def moid_km
    return unless moid_ld

    moid_ld * LUNAR_DISTANCE_KM
  end

  # Show width of asteroid
  def diameter_display
    return unless diameter

    "#{format('%.3f', diameter)} km"
  end

  # How accurate the diameter measurement was
  def diameter_sigma_display
    return unless diameter_sigma

    "± #{format('%.3f', diameter_sigma)} km"
  end

  # Show minimum orbital intersect distance in lunar distance (average distance from earth to moon)
  def moid_ld_display
    return unless moid_ld

    "#{format('%.1f', moid_ld)} LD"
  end

  # Show minimum orbital intersect distance in km
  def moid_km_display
    return unless moid_km

    "#{moid_km.round.to_fs(:delimited)} km"
  end

  # First date it was seen in our sky
  def first_observation_display
    format_observation_date(first_obs)
  end

  # Most recent date it was seen in our sky
  def last_observation_display
    format_observation_date(last_obs)
  end

  private

  # Formatting for our dates
  def format_observation_date(value)
    value&.to_date&.strftime("%B %-d, %Y")
  end
end
