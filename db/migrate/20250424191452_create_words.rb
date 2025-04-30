class CreateWords < ActiveRecord::Migration[8.0]
  def change
    create_table :words do |t|
      t.timestamps
      t.string :value, null: false, index: true
    end
  end
end
