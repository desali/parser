class Comment < ApplicationRecord

    validates :source_id, presence: true
    validates :post_id, presence: true
	validates :title, presence: true, length: { minimum: 2, maximum: 100 }
	validates :date, presence: true
end
