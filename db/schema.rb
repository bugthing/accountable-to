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

ActiveRecord::Schema[8.1].define(version: 2025_10_31_122136) do
  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "goal_messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "goal_id", null: false
    t.integer "input_tokens"
    t.string "model_id"
    t.integer "output_tokens"
    t.string "role"
    t.integer "tool_call_id"
    t.datetime "updated_at", null: false
    t.index ["goal_id"], name: "index_goal_messages_on_goal_id"
    t.index ["tool_call_id"], name: "index_goal_messages_on_tool_call_id"
  end

  create_table "goals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email_token"
    t.string "frequency"
    t.string "model_id"
    t.datetime "removed_at"
    t.string "telegram_chat_id"
    t.string "telegram_token"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["email_token"], name: "index_goals_on_email_token", unique: true
    t.index ["removed_at"], name: "index_goals_on_removed_at"
    t.index ["telegram_chat_id"], name: "index_goals_on_telegram_chat_id", unique: true
    t.index ["telegram_token"], name: "index_goals_on_telegram_token", unique: true
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "tool_calls", force: :cascade do |t|
    t.json "arguments", default: {}
    t.datetime "created_at", null: false
    t.integer "goal_message_id", null: false
    t.string "name", null: false
    t.string "tool_call_id", null: false
    t.datetime "updated_at", null: false
    t.index ["goal_message_id"], name: "index_tool_calls_on_goal_message_id"
    t.index ["tool_call_id"], name: "index_tool_calls_on_tool_call_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "confirmation_token"
    t.datetime "confirmation_token_generated_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "magic_link_token"
    t.datetime "magic_link_token_generated_at"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "goal_messages", "goals"
  add_foreign_key "goals", "users"
  add_foreign_key "tool_calls", "goal_messages"
end
