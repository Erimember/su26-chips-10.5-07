# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  average_rating    :float
#  description       :text
#  issue             :string
#  link              :string           not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representative_id :integer          not null
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#
require 'rails_helper'

RSpec.describe NewsItem do
  let(:representative) { Representative.create!(name: 'Jane Doe', title: 'senator', ocdid: '12345') }

  it 'creates valid article with valid item' do
    news_item = make_spec_article('Free Speech')
    expect(news_item).to be_valid
  end

  it 'does not create article with invalid issue' do
    news_item = make_spec_article('Fake Issue')
    expect(news_item).not_to be_valid
  end

  it 'returns possible issues' do
    expect(described_class.issues).to include('Free Speech', 'Unemployment', 'Equal Pay')
  end
end

def make_spec_article(issue)
  NewsItem.new(
    representative: representative,
    issue: issue,
    title: 'test article',
    link: 'http://www.test.com',
    description: 'Testing'
  )
end
