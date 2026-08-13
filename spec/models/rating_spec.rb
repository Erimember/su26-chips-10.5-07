# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating do
  let(:representative) { Representative.create!(name: 'Jane Doe', title: 'senator', ocdid: '12345') }
  let(:news_item) do
    NewsItem.create!(representative: representative, title: 'Test', link: 'https://t.co',
                     description: 'test', issue: 'Free Speech')
  end
  let(:user) { User.create!(provider: :google_oauth2, uid: '99', first_name: 'A', last_name: 'B') }

  it 'is valid with a value from 1 to 5' do
    expect(described_class.new(news_item: news_item, user: user, value: 4)).to be_valid
  end

  it 'rejects values outside 1..5' do
    expect(described_class.new(news_item: news_item, user: user, value: 6)).not_to be_valid
  end

  it 'allows only one rating per user per article' do
    described_class.create!(news_item: news_item, user: user, value: 3)
    dup = described_class.new(news_item: news_item, user: user, value: 5)
    expect(dup).not_to be_valid
  end

  describe 'average maintenance' do
    let(:other) { User.create!(provider: :github, uid: '77', first_name: 'C', last_name: 'D') }
    let!(:first_rating) { described_class.create!(news_item: news_item, user: user, value: 2) }

    before { described_class.create!(news_item: news_item, user: other, value: 5) }

    it 'averages ratings on create' do
      expect(news_item.reload.average_rating).to eq(3.5)
    end

    it 'recalculates when a rating is updated' do
      first_rating.update!(value: 4)
      expect(news_item.reload.average_rating).to eq(4.5)
    end

    it 'recalculates when a rating is destroyed' do
      first_rating.destroy
      expect(news_item.reload.average_rating).to eq(5.0)
    end
  end
end
