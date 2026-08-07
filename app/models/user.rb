class User < ApplicationRecord
  # This does our password_digest encrypting
  has_secure_password

  # A lot of these "Might" are me future proofing for partial signups

  # Might have signed up to a plan
  belongs_to :plan, optional: true
  # Might have been asigned an asteroid
  belongs_to :upcoming_asteroid,
             class_name: "Asteroid",
             optional: true
  # Could have reserved multiple asteroids
  has_many :asteroids, dependent: :nullify

  # Formats our email properly for storage
  before_validation :normalize_email

  # Do we have a name, an email, an address, and a password longer than 8 char?
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :address, presence: true
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  private

  # The method for formatting our email properly for storage
  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
