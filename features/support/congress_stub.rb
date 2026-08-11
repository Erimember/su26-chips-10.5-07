# frozen_string_literal: true

# Stubs for the congress.gov API, mirroring the geocodio_stub.rb pattern.
# Fixtures are real captured responses (see spec/fixtures/congress_api/).
# NOTE: WebMock gives precedence to the most recently declared matching
# stub, so the more specific /summaries stub is declared last.
Before('@bills') do
  fixtures = Rails.root.join('spec/fixtures/congress_api')
  json = { 'Content-Type' => 'application/json' }

  stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr})
    .to_return(status: 200, body: fixtures.join('bills_119_hr.json').read, headers: json)

  stub_request(:get, %r{api\.congress\.gov/v3/bill\?})
    .to_return(status: 200, body: fixtures.join('bills_recent.json').read, headers: json)

  stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/\d+/summaries})
    .to_return(status: 200, body: fixtures.join('bill_summaries.json').read, headers: json)
end
