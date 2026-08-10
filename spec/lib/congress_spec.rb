# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Congress::Client do
  let(:api_key) { 'test-key' }
  let(:client)  { described_class.new(api_key) }
  let(:json_headers) { { 'Content-Type' => 'application/json' } }

  def fixture(name)
    File.read(Rails.root.join('spec', 'fixtures', 'congress_api', name))
  end

  describe '#initialize' do
    it 'raises ArgumentError when the API key is nil' do
      expect { described_class.new(nil) }.to raise_error(ArgumentError, /missing/)
    end

    it 'raises ArgumentError when the API key is blank' do
      expect { described_class.new('   ') }.to raise_error(ArgumentError, /missing/)
    end
  end

  describe '#get' do
    it 'sends the api_key and Accept header and returns parsed JSON' do
      stub = stub_request(:get, 'https://api.congress.gov/v3/bill')
             .with(query: hash_including('api_key' => api_key),
                   headers: { 'Accept' => 'application/json' })
             .to_return(status: 200, body: fixture('bills_recent.json'), headers: json_headers)

      result = client.get('bill')
      expect(stub).to have_been_requested
      expect(result['bills']).to be_an(Array)
      expect(result['pagination']['count']).to be > 0
    end

    it 'raises on 401 Unauthorized' do
      stub_request(:get, %r{api\.congress\.gov}).to_return(status: 401, body: '{}', headers: { 'Content-Type' => 'application/json' })
      expect { client.get('bill') }.to raise_error(Congress::Error, /Unauthorized/)
    end

    it 'raises on 404 Not Found' do
      stub_request(:get, %r{api\.congress\.gov}).to_return(status: 404, body: '{}', headers: { 'Content-Type' => 'application/json' })
      expect { client.get('bill') }.to raise_error(Congress::Error, /Not found/)
    end

    it 'raises on 429 rate limit' do
      stub_request(:get, %r{api\.congress\.gov}).to_return(status: 429, body: '{}', headers: { 'Content-Type' => 'application/json' })
      expect { client.get('bill') }.to raise_error(Congress::Error, /Rate limit/)
    end

    it 'raises a generic error on other statuses' do
      stub_request(:get, %r{api\.congress\.gov}).to_return(status: 500, body: '{}', headers: { 'Content-Type' => 'application/json' })
      expect { client.get('bill') }.to raise_error(Congress::Error, /API error: 500/)
    end
  end

  describe '#bills' do
    it 'hits /bill/{congress}/{type} when both are given' do
      stub = stub_request(:get, 'https://api.congress.gov/v3/bill/119/hr')
             .with(query: hash_including('limit' => '50'))
             .to_return(status: 200, body: fixture('bills_119_hr.json'), headers: json_headers)

      result = client.bills(congress: 119, type: 'hr', limit: 50).get
      expect(stub).to have_been_requested
      expect(result['bills'].first['type']).to eq('HR')
    end

    it 'hits /bill/{congress} when type is all' do
      stub = stub_request(:get, 'https://api.congress.gov/v3/bill/119')
             .with(query: hash_including('api_key' => api_key))
             .to_return(status: 200, body: fixture('bills_recent.json'), headers: json_headers)

      client.bills(congress: 119).get
      expect(stub).to have_been_requested
    end

    it 'hits /bill with sort when congress is omitted' do
      stub = stub_request(:get, 'https://api.congress.gov/v3/bill')
             .with(query: hash_including('sort' => 'updateDate+desc', 'limit' => '50'))
             .to_return(status: 200, body: fixture('bills_recent.json'), headers: json_headers)

      client.bills(sort: 'updateDate+desc', limit: 50).get
      expect(stub).to have_been_requested
    end
  end

  describe '#bill_detail' do
    it 'returns the parsed bill hash directly' do
      stub_request(:get, 'https://api.congress.gov/v3/bill/119/hr/1')
        .with(query: hash_including('api_key' => api_key))
        .to_return(status: 200, body: fixture('bill_detail.json'), headers: json_headers)

      result = client.bill_detail(congress: 119, bill_type: 'hr', bill_number: 1)
      expect(result['bill']).to be_present
    end
  end

  describe '#summaries' do
    it 'returns the summaries payload for a bill' do
      stub_request(:get, 'https://api.congress.gov/v3/bill/119/hr/96/summaries')
        .with(query: hash_including('api_key' => api_key))
        .to_return(status: 200, body: fixture('bill_summaries.json'), headers: json_headers)

      result = client.summaries(congress: 119, bill_type: 'hr', bill_number: 96)
      expect(result['summaries']).to be_an(Array)
      expect(result['summaries'].first).to have_key('actionDate')
    end
  end

  describe 'pagination' do
    it 'enumerates across pages until a short page is returned' do
      page1 = { 'bills' => Array.new(20) { |i| { 'number' => i.to_s } } }.to_json
      page2 = { 'bills' => [{ 'number' => '20' }] }.to_json

      stub_request(:get, 'https://api.congress.gov/v3/bill/119')
        .with(query: hash_including('offset' => '0'))
        .to_return(status: 200, body: page1, headers: json_headers)
      stub_request(:get, 'https://api.congress.gov/v3/bill/119')
        .with(query: hash_including('offset' => '20'))
        .to_return(status: 200, body: page2, headers: json_headers)

      all = client.bills(congress: 119).all_pages.to_a
      expect(all.size).to eq(21)
    end
  end
end
