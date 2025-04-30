class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.integer :score, default: 0
      t.boolean :solved, default: false
      t.references :word, null: false, foreign_key: true, index: true
      t.integer :speed, default: 0
      t.datetime :last_move
      t.boolean :paused, default: true
      t.boolean :finished, default: false
      t.string :piece, null: false
      t.integer :piece_rotation, default: 0, null: false
      t.integer :x, default: 3, null: false
      t.integer :y, default: 0, null: false
      t.timestamps
    end

    create_table :boards do |t|
      t.timestamps
      t.references :game, null: false, foreign_key: true, index: true
    end

    create_table :squares do |t|
      t.timestamps
      t.references :board, null: false, foreign_key: true, index: true
      t.integer :x
      t.integer :y
      t.boolean :filled, default: false
      t.string :color, default: 'gray'
    end
  end
end
