# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  user_id     :bigint
#  insta_id    :bigint
#  shortcode   :string
#  text        :text
#  timestamp   :datetime
#  locaton     :string
#  location_id :integer
#  vector      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Post < ApplicationRecord
  belongs_to :user, primary_key: :insta_id

  has_many :comments

  validates :user_id, presence: true
  validates :insta_id, presence: true, uniqueness: true
  validates :shortcode, presence: true, uniqueness: true
  validates :text, presence: true
  validates :date, presence: true
  # validates :vector, presence: true
end
