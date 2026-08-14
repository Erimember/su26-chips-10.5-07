# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :require_login!

  # POST /representatives/:representative_id/news_items/:news_item_id/rating
  # One rating per user per article: re-rating updates the existing record.
  def create
    news_item = NewsItem.find(params[:news_item_id])
    rating = news_item.ratings.find_or_initialize_by(user: current_user)
    rating.value = rating_params[:value]

    if rating.save
      flash[:notice] = 'Your rating has been saved.'
    else
      flash[:alert] = rating.errors.full_messages.to_sentence
    end
    redirect_to representative_news_item_path(params[:representative_id], news_item)
  end

  private

  def rating_params
    params.require(:rating).permit(:value)
  end
end
