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

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
