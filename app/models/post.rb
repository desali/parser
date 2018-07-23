# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Post < ApplicationRecord
	has_many :comments

    validates :source_id, presence: true
	validates :title, presence: true, length: { minimum: 2, maximum: 100 }
	validates :date, presence: true
end
