# frozen_string_literal: true

Then /I should see a link to (.*)'s profile page$/ do |name|
  rep = Representative.find_by(name: name)
  expect(page).to have_link(name, href: representative_path(rep))
end

Given /(.*) has a news article$/ do |name|
  rep = Representative.find_by(name: name)
  NewsItem.create!(
    representative: rep,
    title: 'Test News Item',
    link: 'https://testnews.com',
    description: 'test',
    issue: 'Free Speech'
  )
end

When /I visit (.*)'s news articles page$/ do |name|
  rep = Representative.find_by(name: name)
  visit representative_news_items_path(rep)
end
