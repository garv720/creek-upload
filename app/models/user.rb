class User < ApplicationRecord

	attr_accessor :row_number
	validates :first_name, :last_name, :email, presence: true

	validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
