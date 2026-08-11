require 'rails_helper'

RSpec.describe "bills/new", type: :view do
  before(:each) do
    assign(:bill, Bill.new(
      title: "MyString",
      congress: 1,
      number: 1,
      original_chamber: "MyString",
      type: "",
      summary: "MyText"
    ))
  end

  it "renders new bill form" do
    render

    assert_select "form[action=?][method=?]", bills_path, "post" do

      assert_select "input[name=?]", "bill[title]"

      assert_select "input[name=?]", "bill[congress]"

      assert_select "input[name=?]", "bill[number]"

      assert_select "input[name=?]", "bill[original_chamber]"

      assert_select "input[name=?]", "bill[type]"

      assert_select "textarea[name=?]", "bill[summary]"
    end
  end
end
