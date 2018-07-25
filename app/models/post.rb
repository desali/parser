# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  text        :text
#  shortcode   :string
#  created_at  :datetime         not null
#  user_id     :integer
#  locaton     :string
#  location_id :integer
#  vector      :text
#  updated_at  :datetime         not null
#

class Post < ApplicationRecord
  belongs_to :user

  has_many :comments

  validates :text, presence: true
  validates :shortcode, presence: true, uniqueness: true
  validates :user_id, presence: true
  validates :location, presence: true
  validates :location_id, presence: true
  validates :vector, presence: true
end
