class Plan < ApplicationRecord
  has_many :users

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :min_diameter, :max_diameter, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :diameter_range

  scope :ordered_by_min_diameter, -> { order(:min_diameter) }

  private

  def diameter_range
    return if min_diameter.blank? || max_diameter.blank?
    errors.add(:max_diameter, "must be greater than or equal to min diameter") if max_diameter < min_diameter
  end
end
