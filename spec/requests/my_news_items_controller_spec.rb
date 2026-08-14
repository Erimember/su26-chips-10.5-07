# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyNewsItemsController do
  let(:representative) { Representative.create!(name: 'Jane Doe', title: 'senator', ocdid: '12345') }
  let(:news_item) do
    NewsItem.create!(representative: representative, title: 'Test', link: 'https://t.co',
                     description: 'test', issue: 'Free Speech')
  end
  let(:valid_params) do
    { title: 'Fresh coverage', link: 'https://news.example.com', description: 'd',
      issue: 'Immigration', representative_id: representative.id }
  end

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
      get representative_new_my_news_item_url(representative)
      expect(response).to redirect_to(login_url)
    end
  end

  context 'when logged in' do
    before { log_in }

    it 'renders the new form' do
      get representative_new_my_news_item_url(representative)
      expect(response).to be_successful
    end

    it 'renders the edit form' do
      get representative_edit_my_news_item_url(representative, news_item)
      expect(response).to be_successful
    end

    it 'creates a news item with valid params' do
      expect do
        post representative_new_my_news_item_url(representative), params: { news_item: valid_params }
      end.to change(NewsItem, :count).by(1)
    end

    it 'redirects to the created news item' do
      post representative_new_my_news_item_url(representative), params: { news_item: valid_params }
      expect(response).to redirect_to(representative_news_item_path(representative, NewsItem.last))
    end

    it 're-renders new with invalid params' do
      post representative_new_my_news_item_url(representative),
           params: { news_item: valid_params.merge(issue: 'Bogus Issue') }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'updates a news item with valid params' do
      patch representative_edit_my_news_item_url(representative, news_item),
            params: { news_item: { title: 'Updated title' } }
      expect(news_item.reload.title).to eq('Updated title')
    end

    it 're-renders edit with invalid params' do
      patch representative_edit_my_news_item_url(representative, news_item),
            params: { news_item: { issue: 'Not A Real Issue' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'destroys a news item' do
      news_item
      expect do
        delete representative_edit_my_news_item_url(representative, news_item)
      end.to change(NewsItem, :count).by(-1)
    end

    it 'redirects to the news list after destroy' do
      delete representative_edit_my_news_item_url(representative, news_item)
      expect(response).to redirect_to(representative_news_items_path(representative))
    end
  end
end
