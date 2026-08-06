class User < ApplicationRecord
  has_secure_password

  belongs_to :plan, optional: true
  belongs_to :upcoming_asteroid,
             class_name: "Asteroid",
             optional: true

  has_many :asteroids, dependent: :nullify

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :address, presence: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
