# frozen_string_literal: true

module RepresentativesHelper
  def or_unavail(field)
    field.presence || 'N/A'
  end
end
