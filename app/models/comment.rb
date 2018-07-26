# == Schema Information
#
# Table name: comments
#
#  id             :integer          not null, primary key
#  post_id        :bigint
#  owner_id       :bigint
#  owner_username :string
#  insta_id       :bigint
#  text           :text
#  timestamp      :datetime
#  vector         :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Comment < ApplicationRecord
  belongs_to :post, primary_key: :insta_id

  validates :post_id, presence: true
  validates :owner_id, presence: true
  validates :owner_username, presence: true
  validates :insta_id, presence: true, uniqueness: true
  validates :text, presence: true
  validates :date, presence: true
  # validates :vector, presence: true
end
