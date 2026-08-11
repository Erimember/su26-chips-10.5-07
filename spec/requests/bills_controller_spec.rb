# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillsController do
  let(:valid_attributes) do
    { title: 'Lower Energy Costs Act', congress: 119, number: 1,
      original_chamber: 'House', type: 'HR', summary: 'An energy bill.' }
  end

  let(:invalid_attributes) do
    { title: '', congress: nil, number: nil }
  end

  describe 'GET /index' do
    before do
      stub_request(:get, %r{api\.congress\.gov/v3/bill})
        .to_return(status: 200,
                   body: Rails.root.join('spec/fixtures/congress_api/bills_recent.json').read,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'renders a successful response with API results' do
      get bills_url
      expect(response).to be_successful
      expect(response.body).to include('bills-results')
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      bill = Bill.create!(valid_attributes)
      get bill_url(bill)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Bill' do
        expect do
          post bills_url, params: { bill: valid_attributes }
        end.to change(Bill, :count).by(1)
      end

      it 'redirects to the created bill' do
        post bills_url, params: { bill: valid_attributes }
        expect(response).to redirect_to(bill_url(Bill.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Bill' do
        expect do
          post bills_url, params: { bill: invalid_attributes }
        end.not_to change(Bill, :count)
      end

      it 'redirects back to the bills list' do
        post bills_url, params: { bill: invalid_attributes }
        expect(response).to redirect_to(bills_path)
      end
    end
  end
end
