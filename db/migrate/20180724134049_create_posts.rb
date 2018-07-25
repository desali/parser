class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.text :text
      t.string :shortcode
      t.date :created_at
      t.integer :user_id
      t.string :locaton
      t.integer :location_id
      t.text :vector

      t.timestamps
    end
  end
end
