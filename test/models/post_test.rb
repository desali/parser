# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  user_id     :bigint
#  insta_id    :bigint
#  shortcode   :string
#  text        :text
#  date        :datetime
#  locaton     :string
#  location_id :integer
#  vector      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
