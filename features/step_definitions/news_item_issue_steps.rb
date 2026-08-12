# frozen_string_literal: true

Given /(.*) has a news article with issue "(.*)"$/ do |name, issue|
  rep = Representative.find_by(name: name)
  @news_item = NewsItem.create!(
    representative: rep,
    title: 'Test News Item',
    link: 'https://testnews.com',
    description: 'test',
    issue: issue
  )
end

When /I visit the news article$/ do
  visit representative_news_item_path(@news_item.representative, @news_item)
end

Then /I should see an article with issue "(.*)"$/ do |issue|
  expect(page).to have_content(issue)
end

Then /in the table I should see "(.*)"$/ do |issue|
  expect(page).to have_table(text: issue)
end
