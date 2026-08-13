# frozen_string_literal: true

class AddAverageRatingToNewsItems < ActiveRecord::Migration[7.2]
  def change
    add_column :news_items, :average_rating, :float
  end
end
