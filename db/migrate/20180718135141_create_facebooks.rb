class CreateFacebooks < ActiveRecord::Migration[5.2]
  def change
    create_table :facebooks do |t|
      t.text :text

      t.timestamps
    end
  end
end
