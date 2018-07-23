class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :source_id
      t.text :title
      t.date :date

      t.timestamps
    end
  end
end
