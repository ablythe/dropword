# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_24_192418) do
  create_table "boards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id", null: false
    t.index ["game_id"], name: "index_boards_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "score", default: 0
    t.boolean "solved", default: false
    t.integer "word_id", null: false
    t.integer "speed", default: 0
    t.datetime "last_move"
    t.boolean "paused", default: true
    t.boolean "finished", default: false
    t.string "piece", null: false
    t.integer "piece_rotation", default: 0, null: false
    t.integer "x", default: 3, null: false
    t.integer "y", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word_id"], name: "index_games_on_word_id"
  end

  create_table "squares", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "board_id", null: false
    t.integer "x"
    t.integer "y"
    t.boolean "filled", default: false
    t.string "color", default: "gray"
    t.index ["board_id"], name: "index_squares_on_board_id"
  end

  create_table "words", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["value"], name: "index_words_on_value"
  end

  add_foreign_key "boards", "games"
  add_foreign_key "games", "words"
  add_foreign_key "squares", "boards"
end
