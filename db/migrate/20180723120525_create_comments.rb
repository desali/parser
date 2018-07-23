class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :source_id
      t.integer :post_id
      t.text :title
      t.date :date

      t.timestamps
    end
  end
end
