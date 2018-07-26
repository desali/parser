class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :source_id
      t.bigint :insta_id
      t.string :username
      t.string :fullname
      t.text :biography
      t.integer :follower_count
      t.integer :following_count
      t.string :gender
      t.string :is_business
      t.string :location
      t.float :location_x
      t.float :location_y
      t.date :birthdate

      t.timestamps
    end
  end
end
