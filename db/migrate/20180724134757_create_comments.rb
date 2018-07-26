class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.bigint :post_id
      t.bigint :owner_id
      t.string :owner_username
      t.bigint :insta_id
      t.text :text
      t.datetime :date
      t.text :vector

      t.timestamps
    end
  end
end
