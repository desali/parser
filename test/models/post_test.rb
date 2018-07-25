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

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
