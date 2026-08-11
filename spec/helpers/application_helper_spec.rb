# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#bill_display_number' do
    it 'joins the shorthand type and number' do
      expect(helper.bill_display_number({ 'type' => 'HR', 'number' => '123' })).to eq('HR 123')
    end

    it 'works for senate resolution types' do
      expect(helper.bill_display_number({ 'type' => 'SRES', 'number' => '999' })).to eq('SRES 999')
    end
  end

  describe '#format_last_action' do
    let(:action) { { 'text' => 'Became Public Law No: 117-108', 'actionDate' => '2024-04-06' } }

    it 'appends the formatted date to the action text' do
      expect(helper.format_last_action(action)).to eq('Became Public Law No: 117-108 on Apr 6, 2024')
    end

    it 'returns an empty string when the action is blank' do
      expect(helper.format_last_action(nil)).to eq('')
    end

    it 'falls back to the bare text when the date is malformed' do
      bad = { 'text' => 'Referred to committee', 'actionDate' => 'not-a-date' }
      expect(helper.format_last_action(bad)).to eq('Referred to committee')
    end
  end
end
