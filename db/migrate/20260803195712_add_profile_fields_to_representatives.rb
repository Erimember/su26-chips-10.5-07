# frozen_string_literal: true

class AddProfileFieldsToRepresentatives < ActiveRecord::Migration[7.2]
  def change
    add_column :representatives, :party, :string
    add_column :representatives, :photo_url, :string
    add_column :representatives, :address, :string
    add_column :representatives, :phone, :string
    add_column :representatives, :website, :string
    add_column :representatives, :bioguide_id, :string
  end
end
