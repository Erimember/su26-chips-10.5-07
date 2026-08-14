# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyEventsController do
  let(:state) do
    State.create!(name: 'California', symbol: 'CA', fips_code: 6, is_territory: 0,
                  lat_min: 32.5, lat_max: 42.0, long_min: -124.4, long_max: -114.1)
  end
  let(:county) { County.create!(state: state, name: 'Alameda', fips_code: 1, fips_class: 'H1') }
  let(:event) do
    Event.create!(name: 'Town Hall', county: county, description: 'meet',
                  start_time: 1.day.from_now, end_time: 2.days.from_now)
  end
  let(:valid_params) do
    { name: 'Rally', county_id: county.id, description: 'd',
      start_time: 3.days.from_now, end_time: 4.days.from_now }
  end

  def log_in
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: 'github', uid: '77',
      info: { name: 'Test User', email: 'test@example.com' }
    )
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
    get '/auth/github/callback'
  end

  after do
    OmniAuth.config.test_mode = false
    Rails.application.env_config.delete('omniauth.auth')
  end

  context 'when not logged in' do
    it 'redirects to login' do
      get new_my_event_url
      expect(response).to redirect_to(login_url)
    end
  end

  context 'when logged in' do
    before { log_in }

    it 'renders the new form' do
      get new_my_event_url
      expect(response).to be_successful
    end

    it 'renders the edit form' do
      get edit_my_event_url(event)
      expect(response).to be_successful
    end

    it 'creates an event with valid params' do
      expect { post my_events_new_url, params: { event: valid_params } }.to change(Event, :count).by(1)
    end

    it 'redirects to the events list after create' do
      post my_events_new_url, params: { event: valid_params }
      expect(response).to redirect_to(events_path)
    end

    it 're-renders new with invalid params' do
      post my_events_new_url, params: { event: valid_params.merge(end_time: 10.years.ago) }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'updates an event with valid params' do
      patch edit_my_event_url(event), params: { event: { name: 'Updated rally' } }
      expect(event.reload.name).to eq('Updated rally')
    end

    it 're-renders edit with invalid params' do
      patch edit_my_event_url(event), params: { event: { end_time: 10.years.ago } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'destroys an event' do
      event
      expect { delete edit_my_event_url(event) }.to change(Event, :count).by(-1)
    end

    it 'redirects to the events list after destroy' do
      delete edit_my_event_url(event)
      expect(response).to redirect_to(events_url)
    end
  end
end
