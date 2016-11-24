# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161124022017) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: :cascade do |t|
    t.integer  "rows",                                       null: false
    t.integer  "columns",                                    null: false
    t.string   "board",                                                   array: true
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "game_id"
    t.string   "type",       default: "Boards::StringBoard", null: false
  end

  add_index "boards", ["game_id"], name: "index_boards_on_game_id", using: :btree

  create_table "game_players", force: :cascade do |t|
    t.integer "game_id"
    t.integer "player_id"
    t.integer "player_number"
  end

  add_index "game_players", ["game_id"], name: "index_game_players_on_game_id", using: :btree
  add_index "game_players", ["player_id"], name: "index_game_players_on_player_id", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer "status",    default: 0
    t.integer "turn",      default: 0
    t.integer "winner_id"
  end

  add_index "games", ["winner_id"], name: "index_games_on_winner_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.string   "name",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "computer",   default: false
  end

end
