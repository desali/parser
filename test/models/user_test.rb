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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
