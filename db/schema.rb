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

ActiveRecord::Schema[8.1].define(version: 2026_08_06_123137) do
  create_table "asteroids", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.float "diameter"
    t.float "diameter_sigma"
    t.datetime "first_obs"
    t.string "full_name"
    t.string "kind"
    t.datetime "last_obs"
    t.float "moid_ld"
    t.string "spkid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["diameter", "id"], name: "index_asteroids_on_diameter_and_id"
    t.index ["diameter"], name: "index_asteroids_on_diameter"
    t.index ["spkid"], name: "index_asteroids_on_spkid", unique: true
    t.index ["user_id"], name: "index_asteroids_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.float "max_diameter"
    t.float "min_diameter"
    t.string "name", null: false
    t.float "price"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "is_admin", default: false
    t.string "name", null: false
    t.integer "plan_id"
    t.date "plan_start_date"
    t.integer "upcoming_asteroid_id"
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_users_on_plan_id"
    t.index ["upcoming_asteroid_id"], name: "index_users_on_upcoming_asteroid_id"
  end

  add_foreign_key "asteroids", "users"
  add_foreign_key "users", "asteroids", column: "upcoming_asteroid_id"
  add_foreign_key "users", "plans"
end
