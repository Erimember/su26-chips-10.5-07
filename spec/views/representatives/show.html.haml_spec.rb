# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass

require 'rails_helper'

describe 'representatives/show' do
  context 'when I have a full representative' do
    before do
      @representative = Representative.new(
        name: 'John Doe',
        title: 'senator',
        party: 'Democrat',
        phone: '123-456-7890',
        address: '123 N Berkeley St, Berkeley, CA, 94704',
        website: 'https://www.johndoe.com',
        photo_url: 'https://pics.com/photo.jpg'
      )
      render
    end

    it 'displays name' do
      expect(render).to include('John Doe')
    end

    it 'displays title' do
      expect(render).to include('senator')
    end

    it 'displays party' do
      expect(render).to include('Democrat')
    end

    it 'displays photo' do
      expect(render).to include('photo.jpg')
    end

    it 'displays website' do
      expect(render).to include('johndoe.com')
    end
  end

  context 'when I have a rep with missing fields' do
    before do
      @representative = Representative.new(
        name: 'Jane Doe',
        title: 'governer',
        party: 'Republican'
      )
    end

    it 'displays name' do
      expect(render).to include('Jane Doe')
    end

    it 'displays title' do
      expect(render).to include('governer')
    end

    it 'displays missing photo' do
      expect(render).to include('No photo available')
    end

    it 'displays "N/A" without raise' do
      expect(render).to include('N/A')
    end
  end
end
# rubocop:enable RSpec/DescribeClass
