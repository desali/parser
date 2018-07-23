# == Schema Information
#
# Table name: sources
#
#  id         :integer          not null, primary key
#  title      :text
#  link       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Source < ApplicationRecord
	has_many :posts
	has_many :comments through :posts

	validates :title, presence: true, length: { minimum: 2, maximum: 20 }
	validates :link, url: { schemes: ['https'] }
end
