# frozen_string_literal: true

# Stubs for the congress.gov API, mirroring the geocodio_stub.rb pattern.
# Fixtures are real captured responses (see spec/fixtures/congress_api/).
Before('@bills') do
  fixtures = Rails.root.join('spec/fixtures/congress_api')
  json = { 'Content-Type' => 'application/json' }

  # Typed search, e.g. /v3/bill/119/hr (more specific — declared first)
  stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr})
    .to_return(status: 200, body: fixtures.join('bills_119_hr.json').read, headers: json)

  # Base listing, /v3/bill?... (default "most recent" view)
  stub_request(:get, %r{api\.congress\.gov/v3/bill\?})
    .to_return(status: 200, body: fixtures.join('bills_recent.json').read, headers: json)
end
