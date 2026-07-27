# frozen_string_literal: true

require 'faraday'
require 'json'

module Congress
  class Client
    BASE_URL = 'https://api.congress.gov/v3'

    def initialize(api_key)
      raise ArgumentError, 'API key is required' if api_key.nil? || api_key.empty?

      @api_key = api_key
      @conn = Faraday.new(url: BASE_URL) do |f|
        f.params['api_key'] = @api_key
        f.headers['Accept'] = 'application/json'
        f.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      response = @conn.get(path, params)
      JSON.parse(response.body)
    end
  end
end
