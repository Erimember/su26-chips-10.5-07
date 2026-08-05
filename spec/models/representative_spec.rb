# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id          :integer          not null, primary key
#  address     :string
#  name        :string
#  ocdid       :string
#  party       :string
#  phone       :string
#  photo_url   :string
#  title       :string
#  website     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  bioguide_id :string
#
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

RSpec.describe Representative do
  let(:rep_info) do
    JSON.parse(Rails.root.join('spec/fixtures/geocodio_response.json').read)
  end

  describe '.civic_api_to_representative_params' do
    it 'creates a representative for each legislator in the response' do
      expect do
        described_class.civic_api_to_representative_params(rep_info)
      end.to change(described_class, :count).by(2)
    end

    it 'does not create duplicates when called twice with the same response' do
      described_class.civic_api_to_representative_params(rep_info)

      expect do
        described_class.civic_api_to_representative_params(rep_info)
      end.not_to change(described_class, :count)
    end

    it 'returns Representative objects rather than save return values' do
      reps = described_class.civic_api_to_representative_params(rep_info)

      expect(reps).to all(be_a(described_class))
    end

    it 'stores the party from the bio block' do
      described_class.civic_api_to_representative_params(rep_info)

      expect(described_class.find_by(name: 'Jane Doe').party).to eq('Democrat')
    end

    it 'stores the govtrack id from the references block' do
      described_class.civic_api_to_representative_params(rep_info)

      expect(described_class.find_by(name: 'Jane Doe').ocdid).to eq('412345')
    end
  end
end
