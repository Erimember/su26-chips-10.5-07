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
class Bill < ApplicationRecord
  # Disables STI so Rails treats 'type' as a normal column
  self.inheritance_column = nil

  validates :title, :congress, :number, presence: true
end
