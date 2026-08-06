class User < ApplicationRecord
  belongs_to :plan, optional: true
  belongs_to :upcoming_asteroid,
             class_name: "Asteroid",
             optional: true

  has_many :asteroids, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :address, presence: true
end
