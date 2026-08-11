# frozen_string_literal: true

When('I visit the bills page') do
  visit '/bills'
end

When('I search bills for congress {string} and type {string}') do |congress, type|
  fill_in 'congress', with: congress if congress.present?
  select type, from: 'bill_type'
  click_button 'Search'
end

Then('I should see a bills results table') do
  expect(page).to have_css('table#bills-results tbody tr', minimum: 1)
end

Then('I should see how many results are shown out of the total') do
  expect(page).to have_content(/Showing \d+ of [\d,]+ results/)
end

Then('I should see a bill numbered {string}') do |display_number|
  expect(page).to have_content(display_number)
end

Then('I should see a message that congress is required') do
  expect(page).to have_content(/congress.*required/i)
end
