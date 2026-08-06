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

  describe '#update_from_geocodio' do
    let(:legislators) do
      rep_info['results'][0]['response']['results'][0]['fields']['congressional_districts'][0]['current_legislators']
    end

    it 'stores the contact details from the contact block' do
      rep = described_class.new(name: 'Jane Doe')
      rep.update_from_geocodio(legislators[0])

      expect(rep.phone).to eq('202-225-0000')
      expect(rep.website).to eq('https://doe.house.gov')
      expect(rep.address).to eq('1234 Longworth House Office Building; Washington DC 20515')
    end

    it 'stores the bioguide id from the references block' do
      rep = described_class.new(name: 'Jane Doe')
      rep.update_from_geocodio(legislators[0])

      expect(rep.bioguide_id).to eq('D000000')
    end

    it 'leaves missing fields nil rather than raising' do
      rep = described_class.new(name: 'Richard Roe')

      expect { rep.update_from_geocodio(legislators[1]) }.not_to raise_error
      expect(rep.party).to be_nil
      expect(rep.bioguide_id).to be_nil
    end

    it 'constructs correct photo_url' do
      rep = described_class.new(name: 'Lebron James')
      rep.update_from_geocodio(legislators[0])

      expect(rep.bioguide_id).to eq('D000000')
      expect(rep.photo_url).to eq('https://bioguide.congress.gov/bioguide/photo/D/D000000.jpg')
    end

    it 'sets photo_url to nil when bioguide_id is nil' do
      rep = described_class.new(name: 'Lionel Messi')
      expect { rep.update_from_geocodio(legislators[1]) }.not_to raise_error
      expect(rep.bioguide_id).to be_nil
      expect(rep.photo_url).to be_nil
    end
  end
end
