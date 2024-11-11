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

ActiveRecord::Schema[7.2].define(version: 2024_11_11_205300) do
  create_table "blacklisted_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "jti", null: false
    t.text "received_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_blacklisted_tokens_on_jti"
  end

  create_table "blog_posts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "published_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_blog_posts_on_user_id"
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "blog_post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_comments_on_blog_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "api_token"
    t.string "oauth_provider"
    t.string "oauth_uid"
    t.string "profile_picture_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "font_size"
    t.string "color_scheme"
    t.string "language_preference"
    t.boolean "screen_reader_enabled"
    t.integer "followers_count"
    t.integer "following_count"
    t.integer "comments_count"
    t.string "privacy_level"
    t.boolean "can_view_profile"
    t.boolean "can_send_messages"
    t.boolean "can_comment"
    t.json "data_privacy_agreements"
    t.string "theme"
    t.string "locale"
    t.json "notification_preferences"
    t.json "layout_preferences"
    t.boolean "two_factor_enabled"
    t.string "two_factor_method"
    t.datetime "last_login_at"
    t.string "ip_address"
    t.string "browser_info"
    t.json "login_history"
    t.string "referral_code"
    t.json "utm_parameters"
    t.datetime "consent_given_at"
    t.integer "points"
    t.integer "level"
    t.string "rank"
    t.json "achievements"
    t.integer "activity_count"
    t.json "favorite_tags"
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "blog_posts", "users"
  add_foreign_key "comments", "blog_posts"
  add_foreign_key "comments", "users"
end
