Feature: Search congress.gov bills
  As a visitor
  I want to search congress.gov for bills by congress session and bill type
  So that I can find legislation I am interested in

  @bills
  Scenario: Visiting the bills page with no search shows the most recent bills
    When I visit the bills page
    Then I should see a bills results table
    And I should see how many results are shown out of the total

  @bills
  Scenario: Searching by congress and bill type shows matching bills
    When I visit the bills page
    And I search bills for congress "119" and type "hr"
    Then I should see a bills results table
    And I should see a bill numbered "HR 134"

  @bills
  Scenario: Selecting a bill type without a congress number is rejected
    When I visit the bills page
    And I search bills for congress "" and type "hr"
    Then I should see a message that congress is required
