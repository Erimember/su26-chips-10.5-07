require 'rails_helper'

RSpec.describe "bills/index", type: :view do
  before(:each) do
    assign(:bills, [
      Bill.create!(
        title: "Title",
        congress: 2,
        number: 3,
        original_chamber: "Original Chamber",
        type: "Type",
        summary: "MyText"
      ),
      Bill.create!(
        title: "Title",
        congress: 2,
        number: 3,
        original_chamber: "Original Chamber",
        type: "Type",
        summary: "MyText"
      )
    ])
  end

  it "renders a list of bills" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Original Chamber".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Type".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
