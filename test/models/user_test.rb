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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
