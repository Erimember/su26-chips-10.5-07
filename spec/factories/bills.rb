# frozen_string_literal: true

# == Schema Information
#
# Table name: bills
#
#  id               :integer          not null, primary key
#  congress         :integer
#  number           :integer
#  original_chamber :string
#  summary          :text
#  title            :string
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :bill do
    title { 'MyString' }
    congress { 1 }
    number { 1 }
    original_chamber { 'MyString' }
    type { '' }
    summary { 'MyText' }
  end
end
