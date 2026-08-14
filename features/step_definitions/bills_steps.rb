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

When('I save the first bill in the results') do
  expect(page).to have_css('#bills-results tbody tr')
  first('#bills-results tbody tr').click_button('Save')
rescue Selenium::WebDriver::Error::StaleElementReferenceError
  # The page re-rendered between locating the row and clicking (CI timing);
  # the row reference went stale — re-locate and click once more.
  first('#bills-results tbody tr').click_button('Save')
end

Then('I should see the saved bill page with a summary') do
  expect(page).to have_content('Bill was successfully created.')
  expect(page).to have_current_path(%r{/bills/\d+})
  expect(page).to have_content('Summary:')
  expect(Bill.last.summary).to be_present
end

Given('a bill has been saved') do
  @saved_bill = Bill.create!(title: 'Lower Energy Costs Act', congress: 119, number: 1,
                             original_chamber: 'House', type: 'HR', summary: 'An energy bill.')
end

When("I visit that saved bill's page") do
  visit "/bills/#{@saved_bill.id}"
end
