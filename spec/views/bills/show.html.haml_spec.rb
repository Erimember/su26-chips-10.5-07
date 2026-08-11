require 'rails_helper'

RSpec.describe "bills/show", type: :view do
  before(:each) do
    assign(:bill, Bill.create!(
      title: "Title",
      congress: 2,
      number: 3,
      original_chamber: "Original Chamber",
      type: "Type",
      summary: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Original Chamber/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/MyText/)
  end
end
