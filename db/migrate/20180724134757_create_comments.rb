class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.text :text
      t.integer :owner_id
      t.string :owner_username
      t.integer :post_id
      t.date :created_at
      t.text :vector

      t.timestamps
    end
  end
end
