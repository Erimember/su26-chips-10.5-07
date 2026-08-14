# frozen_string_literal: true

class CreateRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :ratings do |t|
      t.references :news_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end
    add_index :ratings, %i[news_item_id user_id], unique: true
  end
end
