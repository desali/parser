class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.bigint :user_id
      t.string :user_username
      t.bigint :insta_id
      t.string :shortcode
      t.text :text
      t.datetime :date
      t.string :locaton
      t.integer :location_id
      t.text :vector

      t.timestamps
    end
  end
end
