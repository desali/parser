class CreateSources < ActiveRecord::Migration[5.2]
  def change
    create_table :sources do |t|
      t.string :title
      t.string :link
      t.string :parse_link

      t.timestamps
    end
  end
end
