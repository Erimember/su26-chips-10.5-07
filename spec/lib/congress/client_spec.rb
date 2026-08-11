# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Congress::Client do
  let(:api_key) { 'test-key' }
  let(:client)  { described_class.new(api_key) }
  let(:json_headers) { { 'Content-Type' => 'application/json' } }

  def fixture(name)
    Rails.root.join('spec', 'fixtures', 'congress_api', name).read
  end

  def stub_endpoint(path, fixture_name, query: {})
    stub_request(:get, "https://api.congress.gov/v3/#{path}")
      .with(query: hash_including(query.merge('api_key' => api_key)),
            headers: { 'Accept' => 'application/json' })
      .to_return(status: 200, body: fixture(fixture_name), headers: json_headers)
  end

  def stub_status(status)
    stub_request(:get, /api\.congress\.gov/)
      .to_return(status: status, body: '{}', headers: json_headers)
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
      stub = stub_endpoint('bill', 'bills_recent.json')
      result = client.get('bill')
      expect(stub).to have_been_requested
      expect(result['bills']).to be_an(Array)
    end

    it 'raises on 401 Unauthorized' do
      stub_status(401)
      expect { client.get('bill') }.to raise_error(Congress::Error, /Unauthorized/)
    end

    it 'raises on 404 Not Found' do
      stub_status(404)
      expect { client.get('bill') }.to raise_error(Congress::Error, /Not found/)
    end

    it 'raises on 429 rate limit' do
      stub_status(429)
      expect { client.get('bill') }.to raise_error(Congress::Error, /Rate limit/)
    end

    it 'raises a generic error on other statuses' do
      stub_status(500)
      expect { client.get('bill') }.to raise_error(Congress::Error, /API error: 500/)
    end
  end

  describe '#bills' do
    it 'hits the congress and type path when both are given' do
      stub = stub_endpoint('bill/119/hr', 'bills_119_hr.json', query: { 'limit' => '50' })
      result = client.bills(congress: 119, type: 'hr', limit: 50).get
      expect(stub).to have_been_requested
      expect(result['bills'].first['type']).to eq('HR')
    end

    it 'hits the congress-only path when type is all' do
      stub = stub_endpoint('bill/119', 'bills_recent.json')
      client.bills(congress: 119).get
      expect(stub).to have_been_requested
    end

    it 'hits the base bill path with sort when congress is omitted' do
      stub = stub_endpoint('bill', 'bills_recent.json', query: { 'sort' => 'updateDate+desc' })
      client.bills(sort: 'updateDate+desc', limit: 50).get
      expect(stub).to have_been_requested
    end
  end

  describe '#bill_detail' do
    it 'returns the parsed bill hash directly' do
      stub_endpoint('bill/119/hr/1', 'bill_detail.json')
      result = client.bill_detail(congress: 119, bill_type: 'hr', bill_number: 1)
      expect(result['bill']).to be_present
    end
  end

  describe '#summaries' do
    it 'returns the summaries payload for a bill' do
      stub_endpoint('bill/119/hr/96/summaries', 'bill_summaries.json')
      result = client.summaries(congress: 119, bill_type: 'hr', bill_number: 96)
      expect(result['summaries'].first).to have_key('actionDate')
    end
  end

  describe 'pagination' do
    def stub_page(offset, bills)
      stub_request(:get, 'https://api.congress.gov/v3/bill/119')
        .with(query: hash_including('offset' => offset.to_s))
        .to_return(status: 200, body: { 'bills' => bills }.to_json, headers: json_headers)
    end

    before do
      stub_page(0, Array.new(20) { |i| { 'number' => i.to_s } })
      stub_page(20, [{ 'number' => '20' }])
    end

    it 'enumerates across pages until a short page is returned' do
      expect(client.bills(congress: 119).all_pages.to_a.size).to eq(21)
    end
  end
end
