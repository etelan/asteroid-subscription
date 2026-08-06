class Asteroid < ApplicationRecord
  belongs_to :user, optional: true
  has_many :upcoming_users,
           class_name: "User",
           foreign_key: :upcoming_asteroid_id,
           inverse_of: :upcoming_asteroid

  validates :spkid, presence: true, uniqueness: true
  validates :diameter, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :moid_ld, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :in_diameter_range, ->(min, max) { where(diameter: min..max) }
end
