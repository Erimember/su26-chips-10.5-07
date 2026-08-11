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
require 'rails_helper'

RSpec.describe Bill, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
