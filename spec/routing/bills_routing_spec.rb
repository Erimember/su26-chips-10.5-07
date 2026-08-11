# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BillsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/bills').to route_to('bills#index')
    end

    it 'routes to #show' do
      expect(get: '/bills/1').to route_to('bills#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/bills').to route_to('bills#create')
    end
  end
end
