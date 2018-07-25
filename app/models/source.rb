# == Schema Information
#
# Table name: sources
#
#  id         :integer          not null, primary key
#  title      :string
#  link       :string
#  parse_link :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Source < ApplicationRecord
  has_many :users
  has_many :posts, through: :users
  has_many :comments, through: :posts

  validates :title, presence: true, uniqueness: true
  validates :link, presence: true, uniqueness: true
  validates :parse_link, presence: true, uniqueness: true
end
