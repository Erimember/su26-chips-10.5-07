# frozen_string_literal: true

require 'webmock/cucumber'

WebMock.disable_net_connect!(allow_localhost: true)

GEOCODIO_FIXTURE = Rails.root.join('spec/fixtures/geocodio_response.json').read

Before do
  stub_request(:post, /api\.geocod\.io/).to_return(
    status:  200,
    body:    GEOCODIO_FIXTURE,
    headers: { 'Content-Type' => 'application/json' }
  )
end
