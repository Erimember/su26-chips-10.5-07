# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RatingsController do
  let(:representative) { Representative.create!(name: 'Jane Doe', title: 'senator', ocdid: '12345') }
  let(:news_item) do
    NewsItem.create!(representative: representative, title: 'Test', link: 'https://t.co',
                     description: 'test', issue: 'Free Speech')
  end
  let(:rating_url) { representative_news_item_rating_path(representative, news_item) }

  def log_in
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github', uid: '77',
      info: { name: 'Test User', email: 'test@example.com' }
    )
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
    get '/auth/github/callback'
  end

  after do
    OmniAuth.config.test_mode = false
    Rails.application.env_config.delete('omniauth.auth')
  end

  context 'when not logged in' do
    it 'redirects to login' do
      post rating_url, params: { rating: { value: 4 } }
      expect(response).to redirect_to(login_url)
    end

    it 'does not create a rating' do
      expect { post rating_url, params: { rating: { value: 4 } } }.not_to change(Rating, :count)
    end
  end

  context 'when logged in' do
    before { log_in }

    it 'creates a rating and refreshes the article average' do
      post rating_url, params: { rating: { value: 4 } }
      expect(news_item.reload.average_rating).to eq(4.0)
    end

    it 'updates the existing rating instead of creating a second one' do
      post rating_url, params: { rating: { value: 2 } }
      expect { post rating_url, params: { rating: { value: 5 } } }.not_to change(Rating, :count)
      expect(news_item.reload.average_rating).to eq(5.0)
    end

    it 'rejects out-of-range values' do
      post rating_url, params: { rating: { value: 9 } }
      expect(news_item.reload.average_rating).to be_nil
    end

    it 'redirects back to the news item page' do
      post rating_url, params: { rating: { value: 4 } }
      expect(response).to redirect_to(representative_news_item_path(representative, news_item))
    end
  end
end
