# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  source_id       :integer
#  insta_id        :bigint
#  username        :string
#  fullname        :string
#  biography       :text
#  follower_count  :integer
#  following_count :integer
#  gender          :string
#  is_business     :string
#  location        :string
#  location_x      :float
#  location_y      :float
#  birthdate       :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  belongs_to :source

  has_many :posts
  has_many :comments, through: :posts

  validates :source_id, presence: true
  validates :insta_id, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :fullname, presence: true
  validates :biography, presence: true
  validates :follower_count, presence: true
  validates :following_count, presence: true
end
