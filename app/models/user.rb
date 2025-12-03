# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string
#  name            :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# User model for authentication and authorization.
# Uses bcrypt for password encryption and JWT for token generation.
#
class User < ApplicationRecord
  # Encrypt passwords using bcrypt
  has_secure_password

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Associations
  has_many :analyses, dependent: :destroy

  # Generate JWT token for the user
  # @return [String] JWT token
  def generate_jwt_token
    JwtService.encode(user_id: id)
  end
end
