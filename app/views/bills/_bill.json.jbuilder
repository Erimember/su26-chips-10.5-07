# frozen_string_literal: true

json.extract! bill, :id, :title, :congress, :number, :original_chamber, :type, :summary, :created_at, :updated_at
json.url bill_url(bill, format: :json)
