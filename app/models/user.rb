# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string
#  fullname        :string
#  biography       :text
#  follower_count  :integer
#  following_count :integer
#  source_id       :integer
#  gender          :string
#  birthdate       :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  belongs_to :source

  has_many :posts
  has_many :comments, through: :posts

  validates :username, presence: true, uniqueness: true
  validates :fullname, presence: true
  validates :biography, presence: true
  validates :follower_count, presence: true
  validates :following_count, presence: true
  validates :source_id, presence: true
  validates :gender, presence: true
  validates :birthdate, presence: true
end
