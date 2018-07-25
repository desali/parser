# == Schema Information
#
# Table name: comments
#
#  id             :integer          not null, primary key
#  text           :text
#  owner_id       :integer
#  owner_username :string
#  post_id        :integer
#  created_at     :datetime         not null
#  vector         :text
#  updated_at     :datetime         not null
#

class Comment < ApplicationRecord
  belongs_to :post

  validates :text, presence: true
  validates :owner_id, presence: true
  validates :owner_username, presence: true
  validates :post_id, presence: true
  validates :vector, presence: true
end
