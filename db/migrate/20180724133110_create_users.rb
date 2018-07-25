class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :fullname
      t.text :biography
      t.integer :follower_count
      t.integer :following_count
      t.integer :source_id
      t.string :gender
      t.date :birthdate

      t.timestamps
    end
  end
end
