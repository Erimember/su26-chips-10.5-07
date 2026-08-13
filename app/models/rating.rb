# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :news_item
  belongs_to :user

  validates :value, inclusion: { in: 1..5, message: 'must be between 1 and 5' }
  validates :user_id, uniqueness: { scope: :news_item_id }

  after_destroy :refresh_average
  after_save :refresh_average

  private

  def refresh_average
    news_item.update!(average_rating: news_item.ratings.average(:value)&.round(2))
  end
end
