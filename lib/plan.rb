class Plan < ApplicationRecord
  has_many :users

  validates :name, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :min_diameter, :max_diameter, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :diameter_range

  private

  def diameter_range
    return if min_diameter.blank? || max_diameter.blank?
    errors.add(:max_diameter, "must be greater than or equal to min diameter") if max_diameter < min_diameter
  end
end
